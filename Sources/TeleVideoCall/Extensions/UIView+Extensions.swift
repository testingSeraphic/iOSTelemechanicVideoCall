//
//  UIView+Extensions.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 28/10/24.
//

import Foundation
import UIKit

extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat, borderColor: UIColor = .clear, borderWidth: CGFloat = 0) {
        // Remove any previously added border layers
        self.layer.sublayers?.removeAll { $0 is CAShapeLayer && $0 != self.layer.mask }
        
        // Create a path for the rounded corners
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        // Create the mask layer for the corners
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        
        // Create a shape layer for the border
        let borderLayer = CAShapeLayer()
        borderLayer.path = path.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = self.bounds
        
        // Add the border layer
        self.layer.addSublayer(borderLayer)
    }
    
}

extension UIView {
    
    func roundExtensionCorners(_ corners: UIRectCorner, radius: CGFloat, borderColor: UIColor = .clear, borderWidth: CGFloat = 0) {
        // Ensure layout is up to date
        self.layoutIfNeeded()
        
        // Remove any previously added border layers
        self.layer.sublayers?.removeAll { $0 is CAShapeLayer && $0 != self.layer.mask }
        
        // Create a path for the rounded corners
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        // Create the mask layer for the corners
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        
        // Create a shape layer for the border
        let borderLayer = CAShapeLayer()
        borderLayer.path = path.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = self.bounds
        
        // Add the border layer
        self.layer.addSublayer(borderLayer)
    }
}

extension UIView {
    func addInnerShadow(borderWidth: CGFloat = 2, shadowRadius: CGFloat = 5, shadowOpacity: Float = 0.5, shadowColor: UIColor = .black) {
        self.layoutIfNeeded()
        // Remove any existing inner shadow layers
        self.layer.sublayers?.removeAll { $0.name == "InnerShadowLayer" }
        
        // Create an inner shadow layer
        let shadowLayer = CALayer()
        shadowLayer.frame = bounds
        shadowLayer.name = "InnerShadowLayer"
        
        // Set up the shadow path
        let path = UIBezierPath(rect: bounds.insetBy(dx: -shadowRadius, dy: -shadowRadius))
        let cutoutPath = UIBezierPath(rect: bounds).reversing()
        path.append(cutoutPath)
        
        // Apply shadow settings
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        shadowLayer.mask = maskLayer
        shadowLayer.shadowPath = path.cgPath
        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.shadowOffset = .zero
        shadowLayer.shadowOpacity = shadowOpacity
        shadowLayer.shadowRadius = shadowRadius
        
        // Add border if needed
        if borderWidth > 0 {
            let borderLayer = CAShapeLayer()
            borderLayer.path = UIBezierPath(rect: bounds).cgPath
            borderLayer.lineWidth = borderWidth * 2
            borderLayer.strokeColor = shadowColor.cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
            shadowLayer.addSublayer(borderLayer)
        }
        
        // Add the inner shadow layer to the view's layer
        self.layer.addSublayer(shadowLayer)
    }
}

extension UIView {
  func captureScreenshot() -> UIImage? {
    let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
    return renderer.image { context in
      self.layer.render(in: context.cgContext)
    }
  }
}





