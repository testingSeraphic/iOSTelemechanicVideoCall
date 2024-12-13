//
//  UImageView+Extensions.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 21/11/24.
//

import Foundation
import UIKit

extension UIImageView {
    /// Sets an image from a URL asynchronously.
    /// - Parameter urlString: The URL string of the image.
    func setImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        // Fetch the image data asynchronously
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle errors
            if let error = error {
                print("Failed to fetch image: \(error.localizedDescription)")
                return
            }
            
            // Validate response and data
            guard let data = data, let image = UIImage(data: data) else {
                print("Invalid image data")
                return
            }
            
            // Update the UIImageView on the main thread
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
