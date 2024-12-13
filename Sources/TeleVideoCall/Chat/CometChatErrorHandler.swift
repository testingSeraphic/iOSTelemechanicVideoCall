//
//  CometChatErrorHandler.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 10/12/24.
//

import Foundation
import UIKit

class CometChatErrorHandler {
    // Singleton instance
    static let shared = CometChatErrorHandler()
    
    private init() {}

    /// Handles an error based on its code and shows an appropriate alert.
    /// - Parameters:
    ///   - errorCode: The error code to handle.
    ///   - viewController: The view controller to present the alert on.
    func handleError(errorCode: String, on viewController: UIViewController) {
        switch errorCode {
        case "ERR_BLOCKED_BY_EXTENSION":
            showAlert(
                title: "Access Blocked",
                message: "The text you entered is restricted.",
                on: viewController
            )
        default:
            showAlert(
                title: "Error",
                message: "An unexpected error occurred. Please try again later.",
                on: viewController
            )
        }
    }
    
    /// Displays an alert with the given title and message.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message of the alert.
    ///   - viewController: The view controller to present the alert on.
    private func showAlert(title: String, message: String, on viewController: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            viewController.present(alert, animated: true)
        }
    }
}

