//
//  CustomScreenRecorder.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 04/11/24.
//


import Foundation
import ReplayKit
import Photos

public enum ScreenRecorderError: Error {
    case notAvailable
    case photoLibraryAccessNotGranted
    case alreadyRecording // New error case for recording already in progress
}

final public class ScreenRecorder {
    private var videoOutputURL: URL?
    private var videoWriter: AVAssetWriter?
    private var videoWriterInput: AVAssetWriterInput?
    private var micAudioWriterInput: AVAssetWriterInput?
    private var appAudioWriterInput: AVAssetWriterInput?
    private var recordAudio = true
    private var isFinished = false // Track if the writing is finished
    private var isRecording = false // Track if recording is active
    private var saveToCameraRoll = false
    let recorder = RPScreenRecorder.shared()
 
    
    public func checkScreenRecordingPermission(completion: @escaping (Bool) -> Void) {
        if #available(iOS 12.0, *) {
                   // Check the screen recording permission status
                   RPScreenRecorder.shared().isAvailable ? completion(true) : completion(false)
               } else {
                   // For older iOS versions, default to true or handle accordingly
                   completion(true)
               }
       }
    
    public func checkMicrophonePermission(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            let currentStatus = AVAudioApplication.shared.recordPermission
            switch currentStatus {
            case .granted:
                completion(true) // Permission granted
            case .denied:
                completion(false) // Permission denied
            case .undetermined:
                AVAudioApplication.requestRecordPermission { granted in
                    completion(granted) // Completion handler with granted status
                }
            @unknown default:
                completion(false) // Handle unexpected status
            }
        } else {
            let currentStatus = AVAudioSession.sharedInstance().recordPermission
            switch currentStatus {
            case .granted:
                completion(true) // Permission granted
            case .denied:
                completion(false) // Permission denied
            case .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    completion(granted) // Completion handler with granted status
                }
            @unknown default:
                completion(false) // Handle unexpected status
            }
        }
    }


    public func startRecording(to outputURL: URL? = nil,
                               size: CGSize? = nil,
                               saveToCameraRoll: Bool = false,
                               recordAudio: Bool = true,
                               errorHandler: @escaping (Error?) -> Void) {
        guard !isFinished else {
            errorHandler(ScreenRecorderError.notAvailable)
            return
        }
        guard !isRecording else {
            errorHandler(ScreenRecorderError.alreadyRecording)
            return
        }

        self.saveToCameraRoll = saveToCameraRoll

        // Check for screen recording permission before starting recording
        checkScreenRecordingPermission { [weak self] available in
            guard let self = self else { return }
            
            if !available {
                errorHandler(ScreenRecorderError.notAvailable)
                return
            }

            // Check for microphone permission before starting recording
            self.checkMicrophonePermission { granted in
                if !granted {
                    errorHandler(ScreenRecorderError.photoLibraryAccessNotGranted)
                    return
                }

                do {
                    try self.createVideoWriter(in: outputURL)
                    self.addVideoWriterInput(size: size)
                    self.recordAudio = recordAudio
                    self.recorder.isMicrophoneEnabled = recordAudio

                    if recordAudio {
                        self.micAudioWriterInput = self.createAndAddAudioInput()
                        self.appAudioWriterInput = self.createAndAddAudioInput()
                    }

                    self.isRecording = true
                    self.startCapture(handler: { (error: Error?) in
                        errorHandler(error)
                    })
                } catch {
                    errorHandler(error)
                }
            }
        }
    }


    public func stopRecording(handler: @escaping (Error?) -> Void) {
        guard isRecording else {
            handler(nil) // If not currently recording, return without doing anything
            return
        }
        
        isRecording = false // Set the flag to prevent further writing
        isFinished = true // Mark as finished

        recorder.stopCapture { error in
            if let error = error {
                handler(error)
                return
            }

            self.videoWriterInput?.markAsFinished()
            if self.recordAudio {
                self.micAudioWriterInput?.markAsFinished()
                self.appAudioWriterInput?.markAsFinished()
            }

            // Check if videoWriter is still in a writable state before finishing
            if self.videoWriter?.status == .writing {
                self.videoWriter?.finishWriting {
                    self.saveVideoToCameraRollAfterAuthorized(handler: handler)
                }
            } else {
                handler(nil) // If already finished, just call the handler with no error
            }
        }
    }

    private func createVideoWriter(in outputURL: URL? = nil) throws {
        let newVideoOutputURL: URL
        
        if let passedVideoOutput = outputURL {
            self.videoOutputURL = passedVideoOutput
            newVideoOutputURL = passedVideoOutput
        } else {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            newVideoOutputURL = URL(fileURLWithPath: documentsPath.appendingPathComponent("WylerNewVideo.mp4"))
            self.videoOutputURL = newVideoOutputURL
        }

        // Remove existing file if it exists
        try? FileManager.default.removeItem(at: newVideoOutputURL)

        videoWriter = try AVAssetWriter(outputURL: newVideoOutputURL, fileType: .mp4)
    }

    private func addVideoWriterInput(size: CGSize?) {
        let passingSize: CGSize = size ?? UIScreen.main.bounds.size
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: passingSize.width,
            AVVideoHeightKey: passingSize.height
        ]

        videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoWriterInput?.expectsMediaDataInRealTime = true
        if let videoWriterInput = videoWriterInput {
            videoWriter?.add(videoWriterInput)
        }
    }
    
    private func createAndAddAudioInput() -> AVAssetWriterInput {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: settings)
        audioInput.expectsMediaDataInRealTime = true
        videoWriter?.add(audioInput)
        
        return audioInput
    }

    private func startCapture(handler: @escaping (Error?) -> Void) {
        guard recorder.isAvailable else {
            return handler(ScreenRecorderError.notAvailable)
        }
        
        recorder.startCapture { (sampleBuffer, sampleType, error) in
            if let error = error {
                handler(error)
                return // Exit early if there's an error
            }
            
            switch sampleType {
            case .video:
                self.handleSampleBuffer(sampleBuffer: sampleBuffer)
            case .audioApp:
                self.add(sample: sampleBuffer, to: self.appAudioWriterInput)
            case .audioMic:
                self.add(sample: sampleBuffer, to: self.micAudioWriterInput)
            default:
                break
            }
        }
    }

    private func handleSampleBuffer(sampleBuffer: CMSampleBuffer) {
        if videoWriter?.status == .unknown {
            videoWriter?.startWriting()
            videoWriter?.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        } else if videoWriter?.status == .writing, videoWriterInput?.isReadyForMoreMediaData == true {
            videoWriterInput?.append(sampleBuffer)
        }
    }
    
    private func add(sample: CMSampleBuffer, to writerInput: AVAssetWriterInput?) {
        if writerInput?.isReadyForMoreMediaData ?? false {
            writerInput?.append(sample)
        }
    }

    private func saveVideoToCameraRollAfterAuthorized(handler: @escaping (Error?) -> Void) {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            saveVideoToCameraRoll(handler: handler)
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    self.saveVideoToCameraRoll(handler: handler)
                } else {
                    handler(ScreenRecorderError.photoLibraryAccessNotGranted)
                }
            }
        }
    }

    private func saveVideoToCameraRoll(handler: @escaping (Error?) -> Void) {
        guard let videoOutputURL = videoOutputURL, saveToCameraRoll else {
            return handler(nil)
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoOutputURL)
        }, completionHandler: { _, error in
            handler(error)
        })
    }
}
