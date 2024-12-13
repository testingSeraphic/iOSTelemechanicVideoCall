//
//  APIClient.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 21/11/24.
//

import Foundation

class APIClient {
    
    /// Sends a POST request with a JSON payload.
    /// - Parameters:
    ///   - urlString: The endpoint URL as a string.
    ///   - payload: The JSON payload as a dictionary.
    ///   - completion: A closure to handle the response or error.
    static func postRequest(
        urlString: String,
        payload: [String: Any],
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        // Validate the URL
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        // Create the URLRequest object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Set the HTTP method to POST
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert payload to JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        // Create the URLSession
        let session = URLSession.shared
        
        // Perform the data task
        let task = session.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Handle the response
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                // Parse the JSON response
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(jsonResponse))
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        // Start the task
        task.resume()
    }
}

