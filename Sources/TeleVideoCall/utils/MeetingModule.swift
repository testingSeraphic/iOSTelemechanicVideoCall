//
//  MeetingModule.swift
//  AmazonChimeSDKDemo
//
//  Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//  SPDX-License-Identifier: Apache-2.0
//

import AmazonChimeSDK
import AVFoundation
import UIKit

let incomingCallKitDelayInSeconds = 10.0

class MeetingModule {
    private static var sharedInstance: MeetingModule?
    private(set) var activeMeeting: MeetingModel?
    private let meetingPresenter = MeetingPresenter()
    private var meetings: [UUID: MeetingModel] = [:]
    private let logger = ConsoleLogger(name: "MeetingModule")
    
    // These need to be cached in case of primary meeting joins in the future
    var cachedOverriddenEndpoint = ""
    var cachedPrimaryExternalMeetingId = ""

    static func shared() -> MeetingModule {
        if sharedInstance == nil {
            sharedInstance = MeetingModule()
        }
        return sharedInstance!
    }

    func prepareMeeting(meetingId: String,
                        selfName: String,
                        overriddenEndpoint: String,
                        primaryExternalMeetingId: String,
                        loginUID: String,
                        remoteUID: String,
                        roleType: String,
                        meetingTimer: String,
                        loginUserName: String,
                        completion: @escaping (Bool) -> Void) {
        requestRecordPermission(audioDeviceCapabilities: .inputAndOutput) { success in
            guard success else {
                completion(false)
                return
            }
            self.cachedOverriddenEndpoint = overriddenEndpoint
            self.cachedPrimaryExternalMeetingId = primaryExternalMeetingId
            JoinRequestService.postJoinRequest(meetingId: meetingId,
                                               name: selfName,
                                               overriddenEndpoint: overriddenEndpoint,
                                               primaryExternalMeetingId: primaryExternalMeetingId) { joinMeetingResponse in
                guard let joinMeetingResponse = joinMeetingResponse else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    return
                }
                let meetingResp = JoinRequestService.getCreateMeetingResponse(from: joinMeetingResponse)
                let attendeeResp = JoinRequestService.getCreateAttendeeResponse(from: joinMeetingResponse)
                let meetingSessionConfiguration = MeetingSessionConfiguration(createMeetingResponse: meetingResp,
                                                   createAttendeeResponse: attendeeResp,
                                                   urlRewriter: self.urlRewriter)
                
                let audioVideoConfig: AudioVideoConfiguration
                if (meetingSessionConfiguration.meetingFeatures.videoMaxResolution == VideoResolution.videoDisabled
                    || meetingSessionConfiguration.meetingFeatures.videoMaxResolution == VideoResolution.videoResolutionHD
                    || meetingSessionConfiguration.meetingFeatures.videoMaxResolution == VideoResolution.videoResolutionFHD
                ) {
                    audioVideoConfig = AudioVideoConfiguration(audioDeviceCapabilities: .inputAndOutput)
                } else {
                    audioVideoConfig = AudioVideoConfiguration(audioDeviceCapabilities: .inputAndOutput)
                }
                
                let meetingModel = MeetingModel(meetingSessionConfig: meetingSessionConfiguration,
                                                meetingId: meetingId,
                                                primaryMeetingId: meetingSessionConfiguration.primaryMeetingId ?? "",
                                                primaryExternalMeetingId: joinMeetingResponse.joinInfo.primaryExternalMeetingId ?? "",
                                                selfName: selfName,
                                                audioVideoConfig: audioVideoConfig,
                                                meetingEndpointUrl: overriddenEndpoint,
                                                loginUID: loginUID,
                                                remoteUID: remoteUID,
                                                meetingTime: meetingTimer,
                                                roleType: roleType,
                                                loginUserName: loginUserName
                                               )
                self.meetings[meetingModel.uuid] = meetingModel

                DispatchQueue.main.async { [weak self] in
                    self?.selectDevice(meetingModel, completion: completion)
                }
                completion(true)
            }
        }
    }
    
    func urlRewriter(url: String) -> String {
        // changing url
        // return url.replacingOccurrences(of: "example.com", with: "my.example.com")
        return url
    }

    func selectDevice(_ meeting: MeetingModel, completion: @escaping (Bool) -> Void) {
        // This is needed to discover bluetooth devices
        configureAudioSession()
        self.activeMeeting = meeting
        MeetingModule.shared().deviceSelected(meeting.deviceSelectionModel)
        completion(true)
//        self.meetingPresenter.showDeviceSelectionView(meetingModel: meeting) { success in
//            if success {
//                self.activeMeeting = meeting
//                MeetingModule.shared().deviceSelected(meeting.deviceSelectionModel)
//            }
//            completion(success)
//        }
    }

    func deviceSelected(_ deviceSelectionModel: DeviceSelectionModel) {
        guard let activeMeeting = activeMeeting else {
            return
        }
        activeMeeting.deviceSelectionModel = deviceSelectionModel
        self.meetingPresenter.showMeetingView(meetingModel: activeMeeting) { _ in }
//        meetingPresenter.dismissActiveMeetingView {
//            self.meetingPresenter.showMeetingView(meetingModel: activeMeeting) { _ in }
//        }
    }

    func joinMeeting(_ meeting: MeetingModel, completion: @escaping (Bool) -> Void) {
        endActiveMeeting {
            self.meetingPresenter.showMeetingView(meetingModel: meeting) { success in
                if success {
                    self.activeMeeting = meeting
                }
                completion(success)
            }
        }
    }

    func getMeeting(with uuid: UUID) -> MeetingModel? {
        return meetings[uuid]
    }

    func endActiveMeeting(completion: @escaping () -> Void) {
        if let activeMeeting = activeMeeting {
            activeMeeting.endMeeting()
            meetingPresenter.dismissActiveMeetingView {
                self.meetings[activeMeeting.uuid] = nil
                self.activeMeeting = nil
                completion()
            }
        } else {
            completion()
        }
    }

    func dismissMeeting(_ meeting: MeetingModel) {
        if let activeMeeting = activeMeeting, meeting.uuid == activeMeeting.uuid {
            meetingPresenter.dismissActiveMeetingView(completion: {})
            meetings[meeting.uuid] = nil
            self.activeMeeting = nil
        } else {
            meetings[meeting.uuid] = nil
        }
    }

    func requestRecordPermission(audioDeviceCapabilities: AudioDeviceCapabilities, completion: @escaping (Bool) -> Void) {
        if audioDeviceCapabilities == .none || audioDeviceCapabilities == .outputOnly {
            completion(true)
            return
        }
        let audioSession = AVAudioSession.sharedInstance()
        switch audioSession.recordPermission {
        case .denied:
            logger.error(msg: "User did not grant audio permission, it should redirect to Settings")
            completion(false)
        case .undetermined:
            audioSession.requestRecordPermission { granted in
                if granted {
                    completion(true)
                } else {
                    self.logger.error(msg: "User did not grant audio permission")
                    completion(false)
                }
            }
        case .granted:
            completion(true)
        @unknown default:
            logger.error(msg: "Audio session record permission unknown case detected")
            completion(false)
        }
    }

    func requestVideoPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
            logger.error(msg: "User did not grant video permission, it should redirect to Settings")
            completion(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if authorized {
                    completion(true)
                } else {
                    self.logger.error(msg: "User did not grant video permission")
                    completion(false)
                }
            }
        case .authorized:
            completion(true)
        @unknown default:
            logger.error(msg: "AVCaptureDevice authorizationStatus unknown case detected")
            completion(false)
        }
    }

    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            if audioSession.category != .playAndRecord {
                try audioSession.setCategory(AVAudioSession.Category.playAndRecord,
                                             options: AVAudioSession.CategoryOptions.allowBluetooth)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            }
            if audioSession.mode != .voiceChat {
                try audioSession.setMode(.voiceChat)
            }
        } catch {
            logger.error(msg: "Error configuring AVAudioSession: \(error.localizedDescription)")
        }
    }
}
