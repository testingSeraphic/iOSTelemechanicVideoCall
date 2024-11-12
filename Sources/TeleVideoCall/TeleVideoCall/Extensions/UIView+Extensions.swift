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


