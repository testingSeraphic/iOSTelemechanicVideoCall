//
//  DeviceSelectionModel.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 23/10/24.
//

import AmazonChimeSDK
import Foundation

class DeviceSelectionModel {
    let audioDevices: [MediaDevice]
    let videoDevices: [MediaDevice]
    let cameraCaptureSource: DefaultCameraCaptureSource1
    let audioVideoConfig: AudioVideoConfiguration

    lazy var supportedVideoFormat: [[VideoCaptureFormat]] = {
        self.videoDevices.map { videoDevice in
            // Reverse these so the highest resolutions are first
            MediaDevice.listSupportedVideoCaptureFormats(mediaDevice: videoDevice, videoMaxResolution: VideoResolution.videoResolutionFHD).reversed()
        }
    }()

    var selectedAudioDeviceIndex = 0
    var selectedVideoDeviceIndex: Int = 0 {
        didSet {
            cameraCaptureSource.device = selectedVideoDevice
        }
    }

    var selectedVideoFormatIndex = 0 {
        didSet {
            guard let selectedVideoFormat = selectedVideoFormat else { return }
            cameraCaptureSource.format = selectedVideoFormat
        }
    }

    var selectedAudioDevice: MediaDevice {
        return audioDevices[selectedAudioDeviceIndex]
    }

    var selectedVideoDevice: MediaDevice? {
        if videoDevices.count == 0 {
            return nil
        }
        return videoDevices[selectedVideoDeviceIndex]
    }

    var selectedVideoFormat: VideoCaptureFormat? {
        let supportedVideoFormat = self.supportedVideoFormat
        guard supportedVideoFormat.count >= selectedVideoDeviceIndex + 1 else {
            return nil
        }
        return supportedVideoFormat[selectedVideoDeviceIndex][selectedVideoFormatIndex]
    }

    var shouldMirrorPreview: Bool {
        return selectedVideoDevice?.type == MediaDeviceType.videoFrontCamera
    }

    init(deviceController: DeviceController, cameraCaptureSource: DefaultCameraCaptureSource1, audioVideoConfig: AudioVideoConfiguration) {
        audioDevices = deviceController.listAudioDevices().reversed()
        // Reverse these so the front camera is the initial choice
        videoDevices = MediaDevice.listVideoDevices()
        self.cameraCaptureSource = cameraCaptureSource
        self.audioVideoConfig = audioVideoConfig
        cameraCaptureSource.device = selectedVideoDevice
        if (audioVideoConfig.videoMaxResolution == VideoResolution.videoDisabled) {
            return
        }
        guard let selectedVideoFormat = selectedVideoFormat else { return }
        cameraCaptureSource.format = selectedVideoFormat
    }
}
