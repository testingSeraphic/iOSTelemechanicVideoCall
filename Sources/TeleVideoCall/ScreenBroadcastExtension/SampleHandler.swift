//
//  SampleHandler.swift
//  ScreenBroadcastExtension
//
//  Created by Apple on 08/11/24.
//



import ReplayKit
import AVFoundation
import Photos

class SampleHandler: RPBroadcastSampleHandler {

    private var videoOutputURL: URL?
    private var videoWriter: AVAssetWriter?
    private var videoWriterInput: AVAssetWriterInput?
    private var micAudioWriterInput: AVAssetWriterInput?
    private var appAudioWriterInput: AVAssetWriterInput?
    private var startTime: CMTime?

    private let videoQueue = DispatchQueue(label: "videoQueue")
    private let audioQueue = DispatchQueue(label: "audioQueue")

    override init() {
        super.init()
        print("SampleHandler initialized")
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        print("Broadcast started")
        startRecording()
    }

    override func broadcastFinished() {
        print("Broadcast finished")
        stopRecordingAndSave()
    }

    private func startRecording() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Generate a unique filename by appending a timestamp to the base name
        let timestamp = Int(Date().timeIntervalSince1970)
        videoOutputURL = documentsDirectory.appendingPathComponent("broadcastOutput_\(timestamp).mp4")
        
        do {
            try self.createVideoWriter()
            self.addVideoWriterInput()
            self.micAudioWriterInput = self.createAndAddAudioInput()
            self.appAudioWriterInput = self.createAndAddAudioInput()
        } catch {
            print("Failed to create writer: \(error)")
        }
    }
    
    private func createVideoWriter() throws {
        // Remove existing file if it exists
        try? FileManager.default.removeItem(at: videoOutputURL!)

        videoWriter = try AVAssetWriter(outputURL: videoOutputURL!, fileType: .mp4)
    }

    private func createAndAddAudioInput() -> AVAssetWriterInput {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: settings)
        audioInput.expectsMediaDataInRealTime = true
        videoWriter?.add(audioInput)
        
        return audioInput
    }

    private func addVideoWriterInput(size: CGSize = UIScreen.main.bounds.size) {
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height
        ]

        videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoWriterInput?.expectsMediaDataInRealTime = true
        if let videoWriterInput = videoWriterInput {
            videoWriter?.add(videoWriterInput)
        }
    }

    private func stopRecordingAndSave() {
        let semaphore = DispatchSemaphore(value: 0)

        videoWriterInput?.markAsFinished()
        
        if videoWriter?.status == .writing {
            videoWriter?.finishWriting {
                DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                    self.checkPhotoLibraryAuthorizationAndSave(semaphore: semaphore)
                }
            }
        } else {
            semaphore.signal()  // Signal to allow broadcast finish
            return
        }

        // Wait for finishWriting and save to complete before returning
        semaphore.wait()
    }

    private func checkPhotoLibraryAuthorizationAndSave(semaphore: DispatchSemaphore) {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                self.saveToPhotoLibrary(semaphore: semaphore)
            case .denied, .restricted:
                print("Photo library access denied or restricted.")
                semaphore.signal()  // Signal to allow broadcast finish
            case .notDetermined:
                print("Photo library access not determined.")
                semaphore.signal()  // Signal to allow broadcast finish
            @unknown default:
                print("Unknown photo library access status.")
                semaphore.signal()  // Signal to allow broadcast finish
            }
        }
    }

    private func saveToPhotoLibrary(semaphore: DispatchSemaphore) {
        guard let videoURL = videoOutputURL, FileManager.default.fileExists(atPath: videoURL.path) else {
            print("Video file does not exist at path, unable to save.")
            semaphore.signal()  // Signal to allow broadcast finish
            return
        }

        DispatchQueue.main.async {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            }) { success, error in
                if success {
                    print("Video saved to Photo Library")
                } else {
                    print("Error saving video to Photo Library: \(error?.localizedDescription ?? "unknown error")")
                }
                semaphore.signal()  // Signal to allow broadcast finish
            }
        }
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .video:
            print("Processing video buffer, size: \(CMSampleBufferGetTotalSampleSize(sampleBuffer)) bytes")
            self.handleSampleBuffer(sampleBuffer: sampleBuffer)
        case .audioApp:
            print("Processing audio app buffer, size: \(CMSampleBufferGetTotalSampleSize(sampleBuffer)) bytes")
            self.add(sample: sampleBuffer, to: self.appAudioWriterInput)
        case .audioMic:
            print("Processing mic audio buffer, size: \(CMSampleBufferGetTotalSampleSize(sampleBuffer)) bytes")
            self.add(sample: sampleBuffer, to: self.micAudioWriterInput)
        @unknown default:
            fatalError("Unknown sample buffer type")
        }
    }

    private func handleSampleBuffer(sampleBuffer: CMSampleBuffer) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        if videoWriter?.status == .unknown {
            videoWriter?.startWriting()
            videoWriter?.startSession(atSourceTime: timestamp)
        }
        
        if videoWriter?.status == .writing {
            videoQueue.async {
                if self.videoWriterInput?.isReadyForMoreMediaData == true {
                    self.videoWriterInput?.append(sampleBuffer)
                }
            }
        }
    }

    private func add(sample: CMSampleBuffer, to writerInput: AVAssetWriterInput?) {
        if writerInput?.isReadyForMoreMediaData ?? false {
            audioQueue.async {
                writerInput?.append(sample)
            }
        }
    }
}
