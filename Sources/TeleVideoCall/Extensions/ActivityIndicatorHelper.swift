//
//  ActivityIndicatorHelper.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 20/11/24.
//

import UIKit
import NVActivityIndicatorView

//class ActivityIndicatorHelper {
//
//    static let shared = ActivityIndicatorHelper()
//
//    private var overlayWindow: UIWindow?
//    private var activityIndicator: NVActivityIndicatorView?
//    private var backgroundView: UIView?
//
//    private init() { }
//
//    /// Start the activity indicator on top of all views
//    func startLoading(type: NVActivityIndicatorType = .circleStrokeSpin, color: UIColor = .green, size: CGFloat = 50) {
//        // Prevent adding multiple indicators
//        if activityIndicator != nil { return }
//
//        // Create a new overlay window
//        let windowScene = UIApplication.shared.connectedScenes
//            .compactMap { $0 as? UIWindowScene }
//            .first
//        let overlay = UIWindow(frame: UIScreen.main.bounds)
//        overlay.windowLevel = .alert + 1 // Ensure it's above all other views
//        overlay.backgroundColor = .clear
//        overlay.windowScene = windowScene
//        overlay.isHidden = false
//
//        // Add a background view (optional, for dimming effect)
//        let bgView = UIView(frame: overlay.bounds)
//        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        bgView.isUserInteractionEnabled = true // Block interactions
//        overlay.addSubview(bgView)
//        backgroundView = bgView
//
//        // Configure the activity indicator
//        let indicator = NVActivityIndicatorView(
//            frame: CGRect(
//                x: (overlay.frame.width - size) / 2,
//                y: (overlay.frame.height - size) / 2,
//                width: size,
//                height: size
//            ),
//            type: type,
//            color: color,
//            padding: nil
//        )
//        overlay.addSubview(indicator)
//        activityIndicator = indicator
//
//        // Keep a reference to the overlay window
//        overlayWindow = overlay
//
//        // Start animating
//        indicator.startAnimating()
//    }
//
//    /// Stop the activity indicator and remove the overlay
//    func stopLoading() {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            self.activityIndicator?.stopAnimating()
//            self.activityIndicator?.removeFromSuperview()
//            self.backgroundView?.removeFromSuperview()
//            
//            self.overlayWindow?.isHidden = true
//            self.overlayWindow = nil
//            self.activityIndicator = nil
//            self.backgroundView = nil
//        }
//    }
//
//}


class ActivityIndicatorHelper {

    static let shared = ActivityIndicatorHelper()

    private var overlayWindow: UIWindow?
    private var activityIndicator: NVActivityIndicatorView?
    private var backgroundView: UIView?

    private init() { }

    /// Start the activity indicator on top of all views
    func startLoading(type: NVActivityIndicatorType = .circleStrokeSpin, color: UIColor = .green, size: CGFloat = 50) {
        // Prevent adding multiple indicators
        if activityIndicator != nil { return }

        // Create a new overlay window
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
        let overlay = UIWindow(frame: UIScreen.main.bounds)
        overlay.windowLevel = .alert + 1 // Ensure it's above all other views
        overlay.backgroundColor = .clear
        overlay.windowScene = windowScene
        overlay.isHidden = false

        // Add a background view (optional, for dimming effect)
        let bgView = UIView(frame: overlay.bounds)
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        bgView.isUserInteractionEnabled = true // Block interactions
        overlay.addSubview(bgView)
        backgroundView = bgView

        // Configure the activity indicator
        let indicator = NVActivityIndicatorView(
            frame: CGRect(
                x: (overlay.frame.width - size) / 2,
                y: (overlay.frame.height - size) / 2,
                width: size,
                height: size
            ),
            type: type,
            color: color,
            padding: nil
        )
        overlay.addSubview(indicator)
        activityIndicator = indicator

        // Keep a reference to the overlay window
        overlayWindow = overlay

        // Start animating
        indicator.startAnimating()
    }

    /// Start the activity indicator on a specific view
    func startLoading(on view: UIView, type: NVActivityIndicatorType = .circleStrokeSpin, color: UIColor = .green, size: CGFloat = 50) {
        // Prevent adding multiple indicators
        if activityIndicator != nil { return }

        // Add a background view (optional, for dimming effect)
        let bgView = UIView(frame: view.bounds)
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        bgView.isUserInteractionEnabled = true // Block interactions
        view.addSubview(bgView)
        backgroundView = bgView

        // Configure the activity indicator
        let indicator = NVActivityIndicatorView(
            frame: CGRect(
                x: (view.frame.width - size) / 2,
                y: (view.frame.height - size) / 2,
                width: size,
                height: size
            ),
            type: type,
            color: color,
            padding: nil
        )
        view.addSubview(indicator)
        activityIndicator = indicator

        // Start animating
        indicator.startAnimating()
    }

    /// Stop the activity indicator and remove the overlay
    func stopLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicator?.stopAnimating()
            self.activityIndicator?.removeFromSuperview()
            self.backgroundView?.removeFromSuperview()
            
            self.overlayWindow?.isHidden = true
            self.overlayWindow = nil
            self.activityIndicator = nil
            self.backgroundView = nil
        }
    }
}

