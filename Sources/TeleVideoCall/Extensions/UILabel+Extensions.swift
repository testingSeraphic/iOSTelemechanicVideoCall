//
//  UILabel+Extensions.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 26/11/24.
//

import Foundation
import UIKit

@IBDesignable
extension UILabel {
    @IBInspectable var strokeColor: UIColor? {
        get {
            return nil // Reading not supported for now
        }
        set {
            updateTextAppearance()
        }
    }

    @IBInspectable var strokeWidth: CGFloat {
        get {
            return 0 // Reading not supported for now
        }
        set {
            updateTextAppearance()
        }
    }

    @IBInspectable var shadowColor: UIColor? {
        get {
            return nil // Reading not supported for now
        }
        set {
            updateTextAppearance()
        }
    }

    @IBInspectable var shadowOffset: CGSize {
        get {
            return CGSize(width: 0, height: 0) // Reading not supported for now
        }
        set {
            updateTextAppearance()
        }
    }

    @IBInspectable var shadowBlurRadius: CGFloat {
        get {
            return 0 // Reading not supported for now
        }
        set {
            updateTextAppearance()
        }
    }

    private func updateTextAppearance() {
        guard let text = self.text else { return }

        let attributedString = NSMutableAttributedString(string: text)

        // Apply stroke
        if let strokeColor = strokeColor {
            attributedString.addAttribute(.strokeColor, value: strokeColor, range: NSRange(location: 0, length: text.count))
            attributedString.addAttribute(.strokeWidth, value: strokeWidth, range: NSRange(location: 0, length: text.count))
        }

        // Apply shadow
        if let shadowColor = shadowColor {
            let shadow = NSShadow()
            shadow.shadowColor = shadowColor
            shadow.shadowOffset = shadowOffset
            shadow.shadowBlurRadius = shadowBlurRadius
            attributedString.addAttribute(.shadow, value: shadow, range: NSRange(location: 0, length: text.count))
        }

        self.attributedText = attributedString
    }
}


extension UILabel {
    func applyStrokeAndShadow(
        strokeColor: UIColor = .black,
        strokeWidth: CGFloat = -0.1,
        shadowColor: UIColor = .black,
        shadowOffset: CGSize = CGSize(width: 1, height: 1),
        shadowBlurRadius: CGFloat = 1.0,
        shadowOpacity: CGFloat = 0.5
    ) {
        guard let text = self.text else { return }

        // Create an attributed string
        let attributedString = NSMutableAttributedString(string: text)

        // Stroke attributes
        attributedString.addAttribute(.strokeColor, value: strokeColor, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.strokeWidth, value: strokeWidth, range: NSRange(location: 0, length: text.count))

        // Shadow attributes
        let shadow = NSShadow()
        shadow.shadowColor = shadowColor.withAlphaComponent(shadowOpacity)
        shadow.shadowOffset = shadowOffset
        shadow.shadowBlurRadius = shadowBlurRadius
        attributedString.addAttribute(.shadow, value: shadow, range: NSRange(location: 0, length: text.count))

        // Apply the attributed string
        self.attributedText = attributedString
    }
}
