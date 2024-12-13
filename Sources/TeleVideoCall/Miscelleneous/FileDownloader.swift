//
//  FileDownloader.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 21/11/24.
//


import Foundation
import UIKit
import Photos

class FileDownloader: NSObject, UIDocumentPickerDelegate {
    static let shared = FileDownloader()
    private override init() {}

    /// Downloads and handles file saving based on type
    /// - Parameters:
    ///   - url: URL of the file to download
    ///   - presentingVC: ViewController to present the picker for non-media files
    ///   - completion: Completion handler with result
    func downloadFile(from url: URL, presentingVC: UIViewController, completion: @escaping (Result<String, Error>) -> Void) {
        
        DispatchQueue.main.async {
            // Start the loader
            ActivityIndicatorHelper.shared.startLoading()
        }
      
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)

        let task = session.downloadTask(with: url) { tempURL, response, error in
            
            ActivityIndicatorHelper.shared.stopLoading()
            
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let tempURL = tempURL else {
                completion(.failure(NSError(domain: "FileDownloader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid temporary URL"])))
                return
            }
            
            print("videoTempURL=", tempURL)

            // Determine file type based on response MIME type or file extension
            let mimeType = response?.mimeType ?? url.pathExtension.lowercased()
            if mimeType.contains("image") {
                self.saveImageToGallery(tempURL: tempURL, completion: completion)
            } else if mimeType.contains("video") {
                self.saveVideoToPhotoLibrary(videoURL: url, completion: completion)
            } else {
                self.presentDocumentPicker(for: tempURL, originalURL: url, presentingVC: presentingVC, completion: completion)
            }
        }
        task.resume()
    }

    // MARK: - Media Handling

    private func saveImageToGallery(tempURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        guard let image = UIImage(contentsOfFile: tempURL.path) else {
            completion(.failure(NSError(domain: "FileDownloader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load image."])))
            return
        }

        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        completion(.success("Image saved to gallery."))
    }

    func saveVideoToPhotoLibrary(videoURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
                do {
                    // Load the video data
                    let videoData = try Data(contentsOf: videoURL)
                    
                    // Save video to the documents directory
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsDirectory.appendingPathComponent("nameX.mp4")
                    
                    try videoData.write(to: fileURL)

                    // Save to the photo library
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
                    }) { success, error in
                        DispatchQueue.main.async {
                            if success {
                                completion(.success("Video saved successfully!"))
                            } else {
                                completion(.failure(error ?? NSError(domain: "VideoProcessing", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to save to photo library"])))
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
    }



    // MARK: - Non-Media File Handling

    private func presentDocumentPicker(
        for tempURL: URL,
        originalURL: URL,
        presentingVC: UIViewController,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let fileName = originalURL.lastPathComponent

        // Copy the temp file to a temporary location for the picker
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempDestinationURL = tempDirectory.appendingPathComponent(fileName)

        do {
            if FileManager.default.fileExists(atPath: tempDestinationURL.path) {
                try FileManager.default.removeItem(at: tempDestinationURL)
            }
            try FileManager.default.copyItem(at: tempURL, to: tempDestinationURL)
        } catch {
            completion(.failure(error))
            return
        }

        // Create and present the document picker
        let documentPicker = UIDocumentPickerViewController(forExporting: [tempDestinationURL])
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet

        self.completionHandler = completion
        presentingVC.present(documentPicker, animated: true, completion: nil)
    }

    // MARK: - UIDocumentPickerDelegate

    private var completionHandler: ((Result<String, Error>) -> Void)?

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        completionHandler?(.failure(NSError(domain: "FileDownloader", code: -1, userInfo: [NSLocalizedDescriptionKey: "User cancelled the operation."])))
        completionHandler = nil
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else {
            completionHandler?(.failure(NSError(domain: "FileDownloader", code: -1, userInfo: [NSLocalizedDescriptionKey: "No URL was selected."])))
            completionHandler = nil
            return
        }

        completionHandler?(.success("File saved to \(selectedURL.path)."))
        completionHandler = nil
    }
}
