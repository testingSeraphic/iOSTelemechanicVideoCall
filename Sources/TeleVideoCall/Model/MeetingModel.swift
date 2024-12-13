//
//  MeetingModel.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 23/10/24.
//

import Foundation
import AmazonChimeSDK
import AVFoundation
import UIKit


class MeetingModel: NSObject {
    enum ActiveMode {
        case roster
        case chat
        case video
        case metrics
    }

    // Dependencies
    let meetingId: String
    let meetingEndpointUrl: String
    let primaryMeetingId: String
    let primaryExternalMeetingId: String
    let selfName: String
    let meetingSessionConfig: MeetingSessionConfiguration
    let audioVideoConfig: AudioVideoConfiguration
    lazy var currentMeetingSession = DefaultMeetingSession(configuration: meetingSessionConfig,
                                                           logger: logger)

    // Utils
    let logger = ConsoleLogger(name: "MeetingModel", level: .INFO)
    let postLogger: PostLogger
    let activeSpeakerObserverId = UUID().uuidString

    // Sub models
    let rosterModel = RosterModel()
    lazy var videoModel = VideoModel(audioVideoFacade: currentMeetingSession.audioVideo,
                                     eventAnalyticsController: currentMeetingSession.eventAnalyticsController)

    lazy var deviceSelectionModel = DeviceSelectionModel(deviceController: currentMeetingSession.audioVideo,
                                                         cameraCaptureSource: videoModel.customSource,
                                                         audioVideoConfig: audioVideoConfig)
    let uuid = UUID()
    
    let loginUID: String
    let remoteUID: String
    let meetingTime: String
    let roleType: String
    let loginUserName: String

    // States
    var isAppInBackground: Bool = false {
        didSet {
            if isAppInBackground {
                wasLocalVideoOn = videoModel.isLocalVideoActive
                if wasLocalVideoOn {
                    videoModel.isLocalVideoActive = false
                }
                videoModel.unsubscribeAllRemoteVideos()
            } else {
                if wasLocalVideoOn {
                    videoModel.isLocalVideoActive = true
                }
                updateRemoteVideoSourceSelection()
            }
            videoModel.updateVideoSourceSubscription()
        }
    }
    private var savedModeBeforeOnHold: ActiveMode?
    private var wasLocalVideoOn: Bool = false

    var activeMode: ActiveMode = .video {
        didSet {
            updateRemoteVideoSourceSelection()
            videoModel.updateVideoSourceSubscription()
            activeModeDidSetHandler?(activeMode)
        }
    }

    private var isMuted = false {
        didSet {
            if isMuted {
                if currentMeetingSession.audioVideo.realtimeLocalMute() {
                    logger.info(msg: "Microphone has been muted")
                }
            } else {
                if currentMeetingSession.audioVideo.realtimeLocalUnmute() {
                    logger.info(msg: "Microphone has been unmuted")
                }
            }
            isMutedHandler?(isMuted)
        }
    }

    private var isEnded = false {
        didSet {
            // This will unbind current tiles.
            videoModel.isEnded = true
            currentMeetingSession.audioVideo.stop()
            isEndedHandler?()
        }
    }

    // State for joining primary meeting will not be true until success,
    // which is achieved asynchronously.  Managed in `MeetingViewController`.
    var isPromotedToPrimaryMeeting = false
    // Store to adjust content takeover behavior
    var primaryMeetingMeetingSessionCredentials: MeetingSessionCredentials? = nil

    var audioDevices: [MediaDevice] {
        return currentMeetingSession.audioVideo.listAudioDevices()
    }

    var currentAudioDevice: MediaDevice? {
        return currentMeetingSession.audioVideo.getActiveAudioDevice()
    }

    // Handlers
    var activeModeDidSetHandler: ((ActiveMode) -> Void)?
    var notifyHandler: ((String) -> Void)?
    var isMutedHandler: ((Bool) -> Void)?
    var isEndedHandler: (() -> Void)?
    var meetingTimerIncrementedHandler: (() -> Void)?
    var pointerDataTransferHandler: ((String) -> Void)?
    var pointerAddedHandler: (() -> Void)?
    var pointerRemovedHandler: (() -> Void)?
    var isRemotePortrait: ((Bool) -> Void)?
    var frontCameraToggle: ((Bool) -> Void)?
    var incrementTimerRequestedHandler: (() -> Void)?
    var incrementTimerApprovedHandler: (() -> Void)?

    init(meetingSessionConfig: MeetingSessionConfiguration,
         meetingId: String,
         primaryMeetingId: String,
         primaryExternalMeetingId: String,
         selfName: String,
         audioVideoConfig: AudioVideoConfiguration,
         meetingEndpointUrl: String,
         loginUID: String,
         remoteUID: String,
         meetingTime: String,
         roleType: String,
         loginUserName: String) {
        self.meetingId = meetingId
        self.meetingEndpointUrl = meetingEndpointUrl.isEmpty ? AppConfiguration.url : meetingEndpointUrl
        self.primaryMeetingId = primaryMeetingId
        self.primaryExternalMeetingId = primaryExternalMeetingId
        self.selfName = selfName
        self.meetingSessionConfig = meetingSessionConfig
        self.audioVideoConfig = audioVideoConfig

        let url = AppConfiguration.url.hasSuffix("/") ? AppConfiguration.url : "\(AppConfiguration.url)/"
        self.postLogger = PostLogger(name: "SDKEvents", configuration: meetingSessionConfig, url: "\(url)log_meeting_event")
        self.loginUID =  loginUID
        self.remoteUID = remoteUID
        self.meetingTime = meetingTime
        self.roleType = roleType
        self.loginUserName = loginUserName
        super.init()

    }

    func bind(videoRenderView: VideoRenderView, tileId: Int) {
        currentMeetingSession.audioVideo.bindVideoView(videoView: videoRenderView, tileId: tileId)
    }
    
    func unbind(tileId: Int) {
        currentMeetingSession.audioVideo.unbindVideoView(tileId: tileId)
      }

    func startMeeting() {
        self.configureAudioSession()
        self.startAudioVideoConnection()
        self.currentMeetingSession.audioVideo.startRemoteVideo()
    }

    func endMeeting() {
        // Notify others that the meeting is ending
        notifyMeetingEnd()
        isEnded = true
    }
    

    func setMute(isMuted: Bool) {
        self.isMuted = isMuted
    }

    func setVoiceFocusEnabled(enabled: Bool) {
        let action = enabled ? "enable" : "disable"
        let success = currentMeetingSession.audioVideo.realtimeSetVoiceFocusEnabled(enabled: enabled)
        if success {
            notify(msg: "Voice Focus \(action)d")
        } else {
            notify(msg: "Failed to \(action) Voice Focus")
        }
    }

    func isVoiceFocusEnabled() -> Bool {
        return currentMeetingSession.audioVideo.realtimeIsVoiceFocusEnabled()
    }

    func getVideoTileDisplayName(for indexPath: IndexPath) -> String {
        var displayName = ""
        if indexPath.item == 0 {
            if videoModel.isLocalVideoActive {
                displayName = selfName
            } else {
                displayName = "Turn on your video"
            }
        } else {
            if let videoTileState = videoModel.getVideoTileState(for: indexPath) {
                displayName = rosterModel.getAttendeeName(for: videoTileState.attendeeId) ?? ""
            }
        }
        return displayName
    }
    
    func getVideoTileAttendeeId(for indexPath: IndexPath) -> String {
        if let videoTileState = videoModel.getVideoTileState(for: indexPath) {
            return videoTileState.attendeeId
        }
        return ""
    }

    func chooseAudioDevice(_ audioDevice: MediaDevice) {
        currentMeetingSession.audioVideo.chooseAudioDevice(mediaDevice: audioDevice)
    }

    func sendDataMessage(_ message: String) {
        do {
            try currentMeetingSession
                .audioVideo
                .realtimeSendDataMessage(topic: "chat",
                                         data: message,
                                         lifetimeMs: 1000)
        } catch {
//            logger.error(msg: "Failed to send message!")
            return
        }

    }

    private func notify(msg: String) {
//        logger.info(msg: msg)
        notifyHandler?(msg)
    }

    private func logWithFunctionName(fnName: String = #function, message: String = "") {
//        logger.info(msg: "[Function] \(fnName) -> \(message)")
    }

    private func setupAudioVideoFacadeObservers() {
        let audioVideo = currentMeetingSession.audioVideo
        audioVideo.addVideoTileObserver(observer: self)
        audioVideo.addRealtimeObserver(observer: self)
        audioVideo.addAudioVideoObserver(observer: self)
        audioVideo.addDeviceChangeObserver(observer: self)
        audioVideo.addActiveSpeakerObserver(policy: DefaultActiveSpeakerPolicy(),
                                            observer: self)
        audioVideo.addRealtimeDataMessageObserver(topic: "endMeeting", observer: self)
        audioVideo.addRealtimeDataMessageObserver(topic: "incrementTimer", observer: self)
        audioVideo.addRealtimeDataMessageObserver(topic: "pointerAdded", observer: self)
        audioVideo.addRealtimeDataMessageObserver(topic: "pointerRemoved", observer: self)
        audioVideo.addRealtimeDataMessageObserver(topic: "pointerDataTransfer", observer: self)
        audioVideo.addRealtimeDataMessageObserver(topic: "portrait", observer: self)
        audioVideo.addRealtimeDataMessageObserver(topic: "landscape", observer: self)
        audioVideo.addRealtimeDataMessageObserver(topic: "cameraToggle", observer: self)
        audioVideo.addRealtimeDataMessageObserver(topic: "incrementTimerRequested", observer: self)
        audioVideo.addRealtimeDataMessageObserver(topic: "incrementTimerApproved", observer: self)
        audioVideo.addEventAnalyticsObserver(observer: self)
    }

    private func removeAudioVideoFacadeObservers() {
        let audioVideo = currentMeetingSession.audioVideo
        audioVideo.removeVideoTileObserver(observer: self)
        audioVideo.removeRealtimeObserver(observer: self)
        audioVideo.removeAudioVideoObserver(observer: self)
        audioVideo.removeDeviceChangeObserver(observer: self)
        audioVideo.removeActiveSpeakerObserver(observer: self)
        audioVideo.removeRealtimeDataMessageObserverFromTopic(topic: "endMeeting")
        audioVideo.removeRealtimeDataMessageObserverFromTopic(topic: "incrementTimer")
        audioVideo.removeRealtimeDataMessageObserverFromTopic(topic: "pointerAdded")
        audioVideo.removeRealtimeDataMessageObserverFromTopic(topic: "pointerRemoved")
        audioVideo.removeRealtimeDataMessageObserverFromTopic(topic: "pointerDataTransfer")
        audioVideo.removeRealtimeDataMessageObserverFromTopic(topic: "portrait")
        audioVideo.removeRealtimeDataMessageObserverFromTopic(topic: "landscape")
        audioVideo.removeRealtimeDataMessageObserverFromTopic(topic: "cameraToggle")
        audioVideo.removeRealtimeDataMessageObserverFromTopic(topic: "incrementTimerRequested")
        audioVideo.removeRealtimeDataMessageObserverFromTopic(topic: "incrementTimerApproved")
        audioVideo.removeEventAnalyticsObserver(observer: self)
    }

    private func configureAudioSession() {
        MeetingModule.shared().configureAudioSession()
    }

    private func startAudioVideoConnection() {
        do {
            setupAudioVideoFacadeObservers()
            try currentMeetingSession.audioVideo.start(audioVideoConfiguration: audioVideoConfig)
        } catch {
//            logger.error(msg: "Error starting the Meeting: \(error.localizedDescription)")
            endMeeting()
        }
    }

    private func logAttendee(attendeeInfo: [AttendeeInfo], action: String) {
        for currentAttendeeInfo in attendeeInfo {
            let attendeeId = currentAttendeeInfo.attendeeId
            if !rosterModel.contains(attendeeId: attendeeId) {
//                logger.error(msg: "Cannot find attendee with attendee id \(attendeeId)" +
//                    " external user id \(currentAttendeeInfo.externalUserId): \(action)")
                continue
            }
//            logger.info(msg: "\(rosterModel.getAttendeeName(for: attendeeId) ?? "nil"): \(action)")
        }
    }

    private func updateRemoteVideoSourceSelection() {
        if activeMode == .video {
            videoModel.removeRemoteVideosNotInCurrentPage()
            
        } else {
            videoModel.unsubscribeAllRemoteVideos()
        }
    }
    
    private func notifyMeetingEnd() {
        do {
            try currentMeetingSession.audioVideo.realtimeSendDataMessage(topic: "endMeeting",
                                                                         data: "",
                                                                         lifetimeMs: 1000)
        } catch {
            logger.error(msg: "Failed to send meeting end notification!")
        }
    }
    
    func toggleCamera(isFront: Bool) {
        do {
            try currentMeetingSession.audioVideo.realtimeSendDataMessage(topic: "cameraToggle",
                                                                         data: "\(isFront)",
                                                                         lifetimeMs: 1000)
        } catch {
            logger.error(msg: "Failed to send meeting end notification!")
        }
    }
    
    func notifyIncrementTime() {
        do {
            try currentMeetingSession.audioVideo.realtimeSendDataMessage(topic: "incrementTimer", data: "increment", lifetimeMs: 1000)
        } catch {
            logger.error(msg: "Failed to send increment time end notification!")
        }
    }
    
    func sendIncrementRequest() {
        do {
            try currentMeetingSession.audioVideo.realtimeSendDataMessage(topic: "incrementTimerRequested", data: "", lifetimeMs: 1000)
        } catch {
            logger.error(msg: "Failed to send increment time end notification!")
        }
    }
    
    func approveIncrementRequest() {
        do {
            try currentMeetingSession.audioVideo.realtimeSendDataMessage(topic: "incrementTimerApproved", data: "", lifetimeMs: 1000)
        } catch {
            logger.error(msg: "Failed to send increment time end notification!")
        }
    }
    
    func sendPointerData(_ data: Data) {
        do {
            try currentMeetingSession.audioVideo.realtimeSendDataMessage(topic: "pointerDataTransfer", data: data, lifetimeMs: 1000)
        } catch {
            logger.error(msg: "Failed to send pointer data notification!")
        }
    }
    
    func addPointer() {
        do {
            try currentMeetingSession.audioVideo.realtimeSendDataMessage(topic: "pointerAdded", data:
                                                                            "", lifetimeMs: 1000)
        } catch {
            logger.error(msg: "Failed to send pointer data notification!")
        }
    }
    
    func removePointer() {
        do {
            try currentMeetingSession.audioVideo.realtimeSendDataMessage(topic: "pointerRemoved", data:
                                                                            "", lifetimeMs: 1000)
        } catch {
            logger.error(msg: "Failed to send pointer data notification!")
        }
    }
    
    func sendOrientation(isPortrait: Bool) {
        do {
            try currentMeetingSession.audioVideo.realtimeSendDataMessage(topic: isPortrait ? "portrait" : "landscape", data:
                                                                            "", lifetimeMs: 1000)
        } catch {
            logger.error(msg: "Failed to send pointer data notification!")
        }
    }
}

// MARK: AudioVideoObserver

extension MeetingModel: AudioVideoObserver {
    func audioSessionDidStopWithStatus(sessionStatus: AmazonChimeSDK.MeetingSessionStatus) {
        
    }
    
    func connectionDidRecover() {
        notifyHandler?("Connection quality has recovered")
        logWithFunctionName()
    }

    func connectionDidBecomePoor() {
        notifyHandler?("Connection quality has become poor")
        logWithFunctionName()
    }

    func videoSessionDidStopWithStatus(sessionStatus: MeetingSessionStatus) {
        logWithFunctionName(message: "\(sessionStatus.statusCode)")
    }

    func audioSessionDidStartConnecting(reconnecting: Bool) {
        notifyHandler?("Audio started connecting. Reconnecting: \(reconnecting)")
        logWithFunctionName(message: "reconnecting \(reconnecting)")
    }

    func audioSessionDidStart(reconnecting: Bool) {
        notifyHandler?("Audio successfully started. Reconnecting: \(reconnecting)")
        logWithFunctionName(message: "reconnecting \(reconnecting)")
        // Start Amazon Voice Focus as soon as audio session started
        setVoiceFocusEnabled(enabled: true)

        // This selection has to be here because if there are bluetooth headset connected,
        // selecting non-bluetooth device before audioVideo.start() will get route overwritten by bluetooth
        // after audio session starts
        if deviceSelectionModel.audioDevices.count>0, let audioDevice = deviceSelectionModel.audioDevices.first {
            chooseAudioDevice(audioDevice)
        }
    }

    func audioSessionDidDrop() {
        notifyHandler?("Audio Session Dropped")
        logWithFunctionName()
    }

    
    func audioSessionDidCancelReconnect() {
        notifyHandler?("Audio cancelled reconnecting")
        logWithFunctionName()
    }

    func videoSessionDidStartConnecting() {
        logWithFunctionName()
    }
    
    func remoteVideoSourcesDidBecomeAvailable(sources: [RemoteVideoSource]) {
        logWithFunctionName()
        sources.forEach { source in
            // Initialize with defaults in case we want to update through UI
            videoModel.addVideoSource(source: source, config: VideoSubscriptionConfiguration())
        }
        updateRemoteVideoSourceSelection()
        videoModel.updateVideoSourceSubscription()
    }
    
    func remoteVideoSourcesDidBecomeUnavailable(sources: [RemoteVideoSource]) {
        logWithFunctionName()
        sources.forEach { source in
            videoModel.removeVideoSource(source: source)
        }
        videoModel.audioVideoFacade.updateVideoSourceSubscriptions(addedOrUpdated: [:], removed: sources)
    }

    func videoSessionDidStartWithStatus(sessionStatus: MeetingSessionStatus) {
        switch sessionStatus.statusCode {
        case .videoAtCapacityViewOnly:
            notifyHandler?("Local video is no longer possible to be enabled")
            logWithFunctionName(message: "\(sessionStatus.statusCode)")
            videoModel.isLocalVideoActive = false
        default:
            logWithFunctionName(message: "\(sessionStatus.statusCode)")
        }
    }
    
    func cameraSendAvailabilityDidChange(available : Bool) {
        logWithFunctionName(message: "Camera Send Available: \(available)")
        videoModel.cameraSendIsAvailable = available
    }
}

// MARK: RealtimeObserver

extension MeetingModel: RealtimeObserver {
    private func isSelfAttendee(attendeeId: String) -> Bool {
        return DefaultModality(id: attendeeId).base == meetingSessionConfig.credentials.attendeeId
            || DefaultModality(id: attendeeId).base == primaryMeetingMeetingSessionCredentials?.attendeeId
    }

    private func removeAttendeesAndReload(attendeeInfo: [AttendeeInfo]) {
        let attendeeIds = attendeeInfo.map { $0.attendeeId }
        rosterModel.removeAttendees(attendeeIds)
        if activeMode == .roster {
            rosterModel.rosterUpdatedHandler?()
        }
    }

    private func attendeesDidJoinWithStatus(attendeeInfo: [AttendeeInfo], status: AttendeeStatus) {
        var newAttendees = [RosterAttendee]()
        for currentAttendeeInfo in attendeeInfo {
            let attendeeId = currentAttendeeInfo.attendeeId
            if !rosterModel.contains(attendeeId: attendeeId) {
                let attendeeName = RosterModel.convertAttendeeName(from: currentAttendeeInfo)
                let newAttendee = RosterAttendee(attendeeId: attendeeId,
                                                 attendeeName: attendeeName,
                                                 volume: .notSpeaking,
                                                 signal: .high)
                newAttendees.append(newAttendee)
                let action = "Joined"
//                logger.info(msg: "attendeeId:\(currentAttendeeInfo.attendeeId) externalUserId:\(currentAttendeeInfo.externalUserId) \(action)")

                // if other attendee starts sharing content, stop content sharing from current device
                let modality = DefaultModality(id: attendeeId)
                if modality.isOfType(type: .content),
                   !isSelfAttendee(attendeeId: attendeeId) {
                    notifyHandler?("\(rosterModel.getAttendeeName(for: modality.base) ?? "") took over the screen share")
                }
            }
        }
        rosterModel.addAttendees(newAttendees)
        if activeMode == .roster {
            rosterModel.rosterUpdatedHandler?()
        }
    }

    func attendeesDidLeave(attendeeInfo: [AttendeeInfo]) {
        logAttendee(attendeeInfo: attendeeInfo, action: "Left")
        removeAttendeesAndReload(attendeeInfo: attendeeInfo)
    }

    func attendeesDidDrop(attendeeInfo: [AttendeeInfo]) {
        for attendee in attendeeInfo {
            notify(msg: "\(attendee.externalUserId) dropped")
        }

        removeAttendeesAndReload(attendeeInfo: attendeeInfo)
    }

    func attendeesDidMute(attendeeInfo: [AttendeeInfo]) {
        logAttendee(attendeeInfo: attendeeInfo, action: "Muted")
    }

    func attendeesDidUnmute(attendeeInfo: [AttendeeInfo]) {
        logAttendee(attendeeInfo: attendeeInfo, action: "Unmuted")
    }

    func volumeDidChange(volumeUpdates: [VolumeUpdate]) {
        for currentVolumeUpdate in volumeUpdates {
            let attendeeId = currentVolumeUpdate.attendeeInfo.attendeeId
            rosterModel.updateVolume(attendeeId: attendeeId, volume: currentVolumeUpdate.volumeLevel)
        }
        if activeMode == .roster {
            rosterModel.rosterUpdatedHandler?()
        }
    }

    func signalStrengthDidChange(signalUpdates: [SignalUpdate]) {
        for currentSignalUpdate in signalUpdates {
            logWithFunctionName(message: "\(currentSignalUpdate.attendeeInfo.externalUserId) \(currentSignalUpdate.signalStrength)")
            let attendeeId = currentSignalUpdate.attendeeInfo.attendeeId
            rosterModel.updateSignal(attendeeId: attendeeId, signal: currentSignalUpdate.signalStrength)
        }
        if activeMode == .roster {
            rosterModel.rosterUpdatedHandler?()
        }
    }

    func attendeesDidJoin(attendeeInfo: [AttendeeInfo]) {
        attendeesDidJoinWithStatus(attendeeInfo: attendeeInfo, status: AttendeeStatus.joined)
    }
}


// MARK: DeviceChangeObserver

extension MeetingModel: DeviceChangeObserver {
    func audioDeviceDidChange(freshAudioDeviceList: [MediaDevice]) {
        let deviceLabels: [String] = freshAudioDeviceList.map { device in "* \(device.label) (\(device.type))" }
        logger.info(msg: deviceLabels.joined(separator: "\n"))
        notifyHandler?("Device availability changed:\nAvailable Devices:\n\(deviceLabels.joined(separator: "\n"))")
    }
}

// MARK: VideoTileObserver

extension MeetingModel: VideoTileObserver {
    func videoTileDidAdd(tileState: VideoTileState) {
        logger.info(msg: "Attempting to add video tile tileId: \(tileState.tileId)" +
            " attendeeId: \(tileState.attendeeId) with size \(tileState.videoStreamContentWidth)*\(tileState.videoStreamContentHeight)")
        if tileState.isContent {
            videoModel.removeContentShareVideoSources()
        } else {
            if tileState.isLocalTile {
                videoModel.setSelfVideoTileState(tileState)
                if activeMode == .video {
                    videoModel.localVideoUpdatedHandler?()
                }
            } else {
                videoModel.addRemoteVideoTileState(tileState, completion: {
                    if self.activeMode == .video {
                        self.videoModel.videoSubscriptionUpdatedHandler?()
                    } else {
                        // Currently not in the video view, no need to render non content share video tiles
                        self.videoModel.removeNonContentShareVideoSources()
                    }
                })
            }
        }
        videoModel.updateVideoSourceSubscription()
    }

    
    func videoTileDidRemove(tileState: VideoTileState) {
        logger.info(msg: "Attempting to remove video tile tileId: \(tileState.tileId)" +
            " attendeeId: \(tileState.attendeeId)")
        currentMeetingSession.audioVideo.unbindVideoView(tileId: tileState.tileId)

        if tileState.isContent {
        } else if tileState.isLocalTile {
            videoModel.setSelfVideoTileState(nil)
            if activeMode == .video {
                videoModel.localVideoUpdatedHandler?()
            }
        } else {
            videoModel.removeRemoteVideoTileState(tileState, completion: { success in
                if success {
                    if self.activeMode == .video {
                        self.videoModel.videoUpdatedHandler?()
                    }
                } else {
                    self.logger.error(msg: "Cannot remove unexisting remote video tile for tileId: \(tileState.tileId)")
                }
            })
        }
    }

    func videoTileDidPause(tileState: VideoTileState) {
        if tileState.pauseState == .pausedForPoorConnection {
            videoModel.updateRemoteVideoTileState(tileState)
        } else {
            let attendeeId = tileState.attendeeId
            let attendeeName = rosterModel.getAttendeeName(for: attendeeId) ?? ""
            notifyHandler?("Video for attendee \(attendeeName) " +
                " has been paused")
        }
    }

    func videoTileDidResume(tileState: VideoTileState) {
        let attendeeId = tileState.attendeeId
        let attendeeName = rosterModel.getAttendeeName(for: attendeeId) ?? ""
        notifyHandler?("Video for attendee \(attendeeName) has been unpaused")
        videoModel.updateRemoteVideoTileState(tileState)
    }

    func videoTileSizeDidChange(tileState: VideoTileState) {
        logger.info(msg: "Video stream content size changed to \(tileState.videoStreamContentWidth)*\(tileState.videoStreamContentHeight) for tileId: \(tileState.tileId)")
    }
}

// MARK: ActiveSpeakerObserver

extension MeetingModel: ActiveSpeakerObserver {
    var observerId: String {
        return activeSpeakerObserverId
    }

    var scoresCallbackIntervalMs: Int {
        return 5000 // 5 second
    }

    func activeSpeakerDidDetect(attendeeInfo: [AttendeeInfo]) {
        videoModel.updateRemoteVideoStatesBasedOnActiveSpeakers(activeSpeakers: attendeeInfo, inVideoMode: activeMode == .video)

        rosterModel.updateActiveSpeakers(attendeeInfo.map { $0.attendeeId })
        if activeMode == .roster {
            rosterModel.rosterUpdatedHandler?()
        }
    }

    func activeSpeakerScoreDidChange(scores: [AttendeeInfo: Double]) {
        let scoresInString = scores.map { (score) -> String in
            let (key, value) = score
            return "\(key.externalUserId): \(value)"
        }.joined(separator: ",")
        logWithFunctionName(message: "\(scoresInString)")
    }
}

// MARK: DataMessageObserver

extension MeetingModel: DataMessageObserver {
    func dataMessageDidReceived(dataMessage: DataMessage) {
        
        if dataMessage.topic == "endMeeting" {
            // Handle the meeting end notification
            isEnded = true
        }
        else if dataMessage.topic == "incrementTimer" {
            meetingTimerIncrementedHandler?()
        }
        
        else if dataMessage.topic == "pointerAdded" {
            pointerAddedHandler?()
        }
        
        else if dataMessage.topic == "pointerRemoved" {
            let data = String(data: dataMessage.data, encoding: .utf8) ?? ""
            pointerRemovedHandler?()
        }
        
        else if dataMessage.topic == "pointerDataTransfer" {
            let data = String(data: dataMessage.data, encoding: .utf8) ?? ""
            pointerDataTransferHandler?(data)
        }
        
        else if dataMessage.topic == "portrait" {
            isRemotePortrait?(true)
        }
        else if dataMessage.topic == "landscape" {
            isRemotePortrait?(false)
        }
        else if dataMessage.topic == "cameraToggle" {
//            print("cameraTopicToggleFetched=")
            let data = String(data: dataMessage.data, encoding: .utf8) ?? ""
//            print("dataCheck=",data)
            frontCameraToggle?(data == "true" ? true : false)
        }
        
        else if dataMessage.topic == "incrementTimerRequested" {
            incrementTimerRequestedHandler?()
        }
        
        else if dataMessage.topic == "incrementTimerApproved" {
            incrementTimerApprovedHandler?()
        }
    }
}

extension MeetingModel: EventAnalyticsObserver {
    func eventDidReceive(name: EventName, attributes: [AnyHashable: Any]) {
        let jsonData = try? JSONSerialization.data(withJSONObject: [
            "name": "\(name)",
            "attributes": toStringKeyDict(attributes.merging(currentMeetingSession.audioVideo.getCommonEventAttributes(),
                                                             uniquingKeysWith: { (_, newVal) -> Any in
                newVal
            }))
        ] as [String : Any], options: [])

        guard let data = jsonData, let msg = String(data: data, encoding: .utf8)  else {
            logger.info(msg: "Dictionary is not in correct format to be serialized")
            return
        }
        postLogger.info(msg: msg)

        switch name {
        case .meetingStartSucceeded:
            logger.info(msg: "Meeting stared on : \(currentMeetingSession.audioVideo.getCommonEventAttributes().toJsonString())")
        case .meetingEnded, .meetingFailed:
            logger.info(msg: "\(currentMeetingSession.audioVideo.getMeetingHistory())")
            postLogger.publishLog()
        default:
            break
        }
    }

    func toStringKeyDict(_ attributes: [AnyHashable: Any]) -> [String: Any] {
        var jsonDict = [String: Any]()
        attributes.forEach { (key, value) in
            jsonDict[String(describing: key)] = String(describing: value)
        }
        return jsonDict
    }
}

extension MeetingModel {
    func getAllVideoTileStates() -> [VideoTileState] {
        var videoTileStates = [VideoTileState]()
        
        let tileCount = videoModel.videoTileCount
        for index in 0..<tileCount {
            let indexPath = IndexPath(item: index, section: 0)
            if let videoTileState = videoModel.getVideoTileState(for: indexPath) {
                videoTileStates.append(videoTileState)
            }
        }
        
        return videoTileStates
    }
}
