//
//  VideoModel.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 23/10/24.
//

import Foundation
import AmazonChimeSDK
import AVFoundation
import UIKit
import AmazonChimeSDK

class VideoModel: NSObject {
    private let remoteVideoTileCountPerPage = 1

    private var currentRemoteVideoPageIndex = 0

    private var selfVideoTileState: VideoTileState?
    private var remoteVideoTileStates: [(Int, VideoTileState)] = []
    private var userPausedVideoTileIds: Set<Int> = Set()
    private var remoteVideoSourceConfigurations: Dictionary<RemoteVideoSource, VideoSubscriptionConfiguration> = Dictionary()
    private var contentShareRemoteVideoSourceConfigurations: Dictionary<RemoteVideoSource, VideoSubscriptionConfiguration> = Dictionary()
    let audioVideoFacade: AudioVideoFacade
    let customSource: DefaultCameraCaptureSource1

    var videoUpdatedHandler: (() -> Void)?
    var videoSubscriptionUpdatedHandler: (() -> Void)?
    var localVideoUpdatedHandler: (() -> Void)?
    let logger = ConsoleLogger(name: "VideoModel")

    private let backgroundBlurProcessor: BackgroundBlurVideoFrameProcessor
    private var backgroundReplacementProcessor: BackgroundReplacementVideoFrameProcessor
    private var backgroundImage: UIImage?

    private var videoSourcesToBeSubscribed: Dictionary<RemoteVideoSource, VideoSubscriptionConfiguration> = Dictionary()
    private var videoSourcesToBeUnsubscribed: Set<RemoteVideoSource> = Set()
    
    var cameraSendIsAvailable: Bool = false

    var pendingRemoteVideoSourceConfigurations: Dictionary<RemoteVideoSource, VideoSubscriptionConfiguration> = Dictionary()

    init(audioVideoFacade: AudioVideoFacade, eventAnalyticsController: EventAnalyticsController) {
        self.audioVideoFacade = audioVideoFacade
        self.customSource = DefaultCameraCaptureSource1(logger: ConsoleLogger(name: "CustomCameraSource"))
        self.customSource.setEventAnalyticsController(eventAnalyticsController: eventAnalyticsController)

        // Create the background replacement image.
        let rect = CGRect(x: 0,
                          y: 0,
                          width: self.customSource.format.width,
                          height: self.customSource.format.height)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.customSource.format.width,
                                                      height: self.customSource.format.height),
                                               false, 0)
        UIColor.blue.setFill()
        UIRectFill(rect)
        let backgroundReplacementImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let backgroundReplacementConfigurations = BackgroundReplacementConfiguration(logger: ConsoleLogger(name: "BackgroundReplacementProcessor"),
                                                                                     backgroundReplacementImage: backgroundReplacementImage)
        self.backgroundReplacementProcessor = BackgroundReplacementVideoFrameProcessor(backgroundReplacementConfiguration: backgroundReplacementConfigurations)

        let backgroundBlurConfigurations = BackgroundBlurConfiguration(logger: ConsoleLogger(name: "BackgroundBlurProcessor"),
                                                                       blurStrength: BackgroundBlurStrength.low)
        self.backgroundBlurProcessor = BackgroundBlurVideoFrameProcessor(backgroundBlurConfiguration: backgroundBlurConfigurations)

        super.init()
    }

    var localVideoMaxBitRateKbps: UInt32 = 0

    var videoTileCount: Int {
        return remoteVideoCountInCurrentPage + 1
    }

    var isLocalVideoActive = false {
        willSet(isLocalVideoActive) {
            if isLocalVideoActive {
                customSource.start()
                startLocalVideo()
            } else {
                customSource.stop()
                stopLocalVideo()
            }
        }
    }

    var isEnded = false {
        didSet(isEnded) {
            if isEnded {
                for tile in remoteVideoTileStates {
                    audioVideoFacade.unbindVideoView(tileId: tile.0)
                }
                if isLocalVideoActive, let selfTile = selfVideoTileState {
                    audioVideoFacade.unbindVideoView(tileId: selfTile.tileId)
                }

                if isUsingExternalVideoSource {
                    self.customSource.removeVideoSink(sink: self.backgroundBlurProcessor)
                    self.customSource.removeVideoSink(sink: self.backgroundReplacementProcessor)
                }

                isLocalVideoActive = false

                audioVideoFacade.stopRemoteVideo()
                customSource.torchEnabled = false
            }
        }
    }

    var isFrontCameraActive: Bool {
        // See comments above isUsingExternalVideoSource
        if let internalCamera = audioVideoFacade.getActiveCamera() {
            return internalCamera.type == .videoFrontCamera
        }
        if let activeCamera = customSource.device {
            return activeCamera.type == .videoFrontCamera
        }
        return false
    }

    // To facilitate demoing and testing both use cases, we account for both our external
    // camera and the camera managed by the facade. Actual applications should
    // only use one or the other
    var isUsingExternalVideoSource = true {
        didSet {
            if isLocalVideoActive {
                startLocalVideo()
            }
        }
    }

    var isUsingBackgroundBlur = false {
        didSet {
            if isLocalVideoActive{
                startLocalVideo()
            }
        }
    }

    var isUsingBackgroundReplacement = false {
        didSet {
            if isLocalVideoActive {
                startLocalVideo()
            }
        }
    }

    private var currentRemoteVideoCount: Int {
        return remoteVideoTileStates.count
    }

    private var remoteVideoStatesInCurrentPage: [(Int, VideoTileState)] {
        let remoteVideoStartIndex = currentRemoteVideoPageIndex * remoteVideoTileCountPerPage
        let remoteVideoEndIndex = min(currentRemoteVideoCount, remoteVideoStartIndex + remoteVideoTileCountPerPage) - 1

        if remoteVideoEndIndex < remoteVideoStartIndex {
            return []
        }
        return Array(remoteVideoTileStates[remoteVideoStartIndex ... remoteVideoEndIndex])
    }

    private var remoteVideoStatesNotInCurrentPage: [(Int, VideoTileState)] {
        let remoteVideoAttendeeIdsInCurrentPage = Set(remoteVideoStatesInCurrentPage.map { $0.1.attendeeId })
        return remoteVideoTileStates.filter { !remoteVideoAttendeeIdsInCurrentPage.contains($0.1.attendeeId) }
    }

    private var remoteVideoCountInCurrentPage: Int {
        return remoteVideoStatesInCurrentPage.count
    }

    private func startLocalVideo() {
        MeetingModule.shared().requestVideoPermission { success in
            if success {
                // See comments above isUsingExternalVideoSource
                if self.isUsingExternalVideoSource {
                    var customVideoSource: VideoSource = self.customSource
                    customVideoSource.removeVideoSink(sink: self.backgroundBlurProcessor)
                    customVideoSource.removeVideoSink(sink: self.backgroundReplacementProcessor)
                    if self.isUsingBackgroundBlur {
                        customVideoSource.addVideoSink(sink: self.backgroundBlurProcessor)
                        customVideoSource = self.backgroundBlurProcessor
                    } else if self.isUsingBackgroundReplacement {
                        customVideoSource.addVideoSink(sink: self.backgroundReplacementProcessor)
                        customVideoSource = self.backgroundReplacementProcessor
                    }
                    // customers could set simulcast here
                    let config = LocalVideoConfiguration(maxBitRateKbps: self.localVideoMaxBitRateKbps)
                    self.audioVideoFacade.startLocalVideo(source: customVideoSource,
                                                          config: config)
                } else {
                    do {
                        try self.audioVideoFacade.startLocalVideo()
                    } catch {
                        self.logger.error(msg: "Error starting local video: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    private func stopLocalVideo() {
        audioVideoFacade.stopLocalVideo()
        // See comments above isUsingExternalVideoSource
        if isUsingExternalVideoSource {
            customSource.stop()
        }
    }

    private func moveVideoSourceFromPendingToNormalByAttendeeId(attendeeId: String) {
        let pendingAttendeeKeyMap = pendingRemoteVideoSourceConfigurations.keys.reduce(into: [String: RemoteVideoSource]()) {
            $0[$1.attendeeId] = $1
        }

        if let source = pendingAttendeeKeyMap[attendeeId] {
            if pendingRemoteVideoSourceConfigurations[source] != nil {
                remoteVideoSourceConfigurations[source] = pendingRemoteVideoSourceConfigurations[source]
                pendingRemoteVideoSourceConfigurations.removeValue(forKey: source)
            }
        }
    }

    private func isAttendeeIdContentShare(attendeeId: String) -> Bool {
        return DefaultModality(id: attendeeId).isOfType(type: .content)
    }

    private func addVideoSourcesToBeSubscribed (toBeAddedOrUpdated: Dictionary<RemoteVideoSource, VideoSubscriptionConfiguration>) {
        for (source, config) in toBeAddedOrUpdated {
            videoSourcesToBeSubscribed[source] = config
            videoSourcesToBeUnsubscribed.remove(source)
        }
    }

    private func addVideoSourcesToBeUnsubscribed (toBeRemoved: Array<RemoteVideoSource>) {
        for source in toBeRemoved {
            videoSourcesToBeSubscribed.removeValue(forKey: source)
            videoSourcesToBeUnsubscribed.insert(source)
        }
    }

    func promoteToPrimaryMeeting(credentials: MeetingSessionCredentials, observer: PrimaryMeetingPromotionObserver) {
        audioVideoFacade.promoteToPrimaryMeeting(credentials: credentials, observer: observer)
    }

    func demoteFromPrimaryMeeting() {
        audioVideoFacade.demoteFromPrimaryMeeting()
    }

    func isRemoteVideoDisplaying(tileId: Int) -> Bool {
        return remoteVideoStatesInCurrentPage.contains(where: { $0.0 == tileId })
    }

    func updateRemoteVideoStatesBasedOnActiveSpeakers(activeSpeakers: [AttendeeInfo], inVideoMode: Bool = false) {
        let activeSpeakerIds = Set(activeSpeakers.map { $0.attendeeId })
        var videoTilesOrderUpdated = false

        // Cast to NSArray to make sure the sorting implementation is stable
        remoteVideoTileStates = (remoteVideoTileStates as NSArray).sortedArray(options: .stable,
                                                                               usingComparator: { (lhs, rhs) -> ComparisonResult in
            let lhsIsActiveSpeaker = activeSpeakerIds.contains((lhs as? (Int, VideoTileState))?.1.attendeeId ?? "")
            let rhsIsActiveSpeaker = activeSpeakerIds.contains((rhs as? (Int, VideoTileState))?.1.attendeeId ?? "")

            if lhsIsActiveSpeaker == rhsIsActiveSpeaker {
                return ComparisonResult.orderedSame
            } else if lhsIsActiveSpeaker && !rhsIsActiveSpeaker {
                return ComparisonResult.orderedAscending
            } else {
                videoTilesOrderUpdated = true
                return ComparisonResult.orderedDescending
            }
        }) as? [(Int, VideoTileState)] ?? []
        for remoteVideoTileState in remoteVideoStatesNotInCurrentPage {
            audioVideoFacade.pauseRemoteVideoTile(tileId: remoteVideoTileState.0)
        }
        if videoTilesOrderUpdated && inVideoMode {
            videoSubscriptionUpdatedHandler?()
            updateVideoSourceSubscription()
        }
    }

    func setSelfVideoTileState(_ videoTileState: VideoTileState?) {
        selfVideoTileState = videoTileState
    }

    func addRemoteVideoTileState(_ videoTileState: VideoTileState, completion: @escaping () -> Void) {
        remoteVideoTileStates.append((videoTileState.tileId, videoTileState))
        moveVideoSourceFromPendingToNormalByAttendeeId(attendeeId: videoTileState.attendeeId)
        completion()
    }

    func removeRemoteVideoTileState(_ videoTileState: VideoTileState, completion: @escaping (Bool) -> Void) {
        if let index = remoteVideoTileStates.firstIndex(where: { $0.0 == videoTileState.tileId }) {
            remoteVideoTileStates.remove(at: index)
            completion(true)
        } else {
            completion(false)
        }
    }

    func updateRemoteVideoTileState(_ videoTileState: VideoTileState) {
        if let index = remoteVideoTileStates.firstIndex(where: { $0.0 == videoTileState.tileId }) {
            remoteVideoTileStates[index] = (videoTileState.tileId, videoTileState)
            videoUpdatedHandler?()
        }
    }

    func resumeAllRemoteVideosInCurrentPageExceptUserPausedVideos() {
        for remoteVideoTileState in remoteVideoStatesInCurrentPage {
            if !userPausedVideoTileIds.contains(remoteVideoTileState.0) {
                audioVideoFacade.resumeRemoteVideoTile(tileId: remoteVideoTileState.0)
            }
        }
    }
    

    func addContentShareVideoSource() {
        addVideoSourcesToBeSubscribed(toBeAddedOrUpdated: contentShareRemoteVideoSourceConfigurations)
    }

    func removeContentShareVideoSources() {
        addVideoSourcesToBeUnsubscribed(toBeRemoved: Array(contentShareRemoteVideoSourceConfigurations.keys))
    }

    func removeNonContentShareVideoSources() {
        addVideoSourcesToBeUnsubscribed(toBeRemoved: Array(remoteVideoSourceConfigurations.keys))
    }

    func pauseAllRemoteVideos() {
        for remoteVideoTileState in remoteVideoTileStates {
            audioVideoFacade.pauseRemoteVideoTile(tileId: remoteVideoTileState.0)
        }
    }

    func unsubscribeAllRemoteVideos() {
        addVideoSourcesToBeUnsubscribed(toBeRemoved: Array(contentShareRemoteVideoSourceConfigurations.keys))
        addVideoSourcesToBeUnsubscribed(toBeRemoved: Array(remoteVideoSourceConfigurations.keys))
    }

    func getRemoteVideoSubscriptionsFromRemoteVideoTileStates(remoteVideoTileStates: [(Int, VideoTileState)]) -> [RemoteVideoSource] {
        var remoteVideoSources: [RemoteVideoSource] = []
        let attendeeKeyMap = remoteVideoSourceConfigurations.keys.reduce(into: [String: RemoteVideoSource]()) {
            $0[$1.attendeeId] = $1
        }
        let attendeeIds = Set(remoteVideoSourceConfigurations.keys.map { $0.attendeeId })
        for remoteVideoTileState in remoteVideoTileStates {
                let attendeeId = String(remoteVideoTileState.1.attendeeId)
            if attendeeIds.contains(attendeeId), let key = attendeeKeyMap[attendeeId] {
                remoteVideoSources.append(key)
            }
        }
        return remoteVideoSources
    }

    func removeRemoteVideosNotInCurrentPage() {
        removeContentShareVideoSources()
        let remoteVideoSourcesNotInCurrPage: [RemoteVideoSource] = getRemoteVideoSubscriptionsFromRemoteVideoTileStates(remoteVideoTileStates: remoteVideoStatesNotInCurrentPage)
        addVideoSourcesToBeUnsubscribed(toBeRemoved: remoteVideoSourcesNotInCurrPage)
    }

    func getVideoTileState(for indexPath: IndexPath) -> VideoTileState? {
        if indexPath.item == 0 {
            return selfVideoTileState
        }
        if indexPath.item > remoteVideoTileCountPerPage {
            return nil
        }
        return remoteVideoStatesInCurrentPage[indexPath.item - 1].1
    }

    func toggleTorch() -> Bool {
        let desiredState = !customSource.torchEnabled
        customSource.torchEnabled = desiredState
        return customSource.torchEnabled == desiredState
    }

    func removeVideoSource(source: RemoteVideoSource) {
        remoteVideoSourceConfigurations.removeValue(forKey: source)
        pendingRemoteVideoSourceConfigurations.removeValue(forKey: source)
        contentShareRemoteVideoSourceConfigurations.removeValue(forKey: source)
    }

    func addVideoSource(source: RemoteVideoSource, config: VideoSubscriptionConfiguration) {
        if isAttendeeIdContentShare(attendeeId: source.attendeeId) {
            contentShareRemoteVideoSourceConfigurations[source] = config
        } else {
            if remoteVideoSourceConfigurations[source] == nil {
                pendingRemoteVideoSourceConfigurations[source] = config
            } else {
                remoteVideoSourceConfigurations[source] = config
            }
        }
    }

    func updateVideoSourceSubscription() {
        if videoSourcesToBeSubscribed.isEmpty && videoSourcesToBeUnsubscribed.isEmpty {
            return
        }
        audioVideoFacade.updateVideoSourceSubscriptions(addedOrUpdated: videoSourcesToBeSubscribed, removed: Array(videoSourcesToBeUnsubscribed))
        videoSourcesToBeSubscribed.removeAll()
        videoSourcesToBeUnsubscribed.removeAll()
    }
}
