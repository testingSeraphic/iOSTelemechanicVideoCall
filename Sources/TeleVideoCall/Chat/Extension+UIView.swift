//
//  Extension+UIView.swift
//  VideoCall
//
//  Created by Manpreet Singh on 17/11/24.
//

import UIKit

extension UIView {
    
    enum SideCellType {
        case left
        case right
    }
    
    func configureAsSideCell(
        type: SideCellType,
        cornerRadii: CGSize = CGSize(width: 12, height: 12),
        borderColor: UIColor = .white,
        borderWidth: CGFloat = 1.0
    ) {
        // Define properties based on the cell type
        let customCorners: UIRectCorner
        let backgroundColorValue: UIColor
        
        switch type {
        case .left:
            customCorners = [.topLeft, .bottomRight, .topRight]
            backgroundColorValue = UIColor(red: 0.883, green: 0.888, blue: 0.91, alpha: 1)
        case .right:
            customCorners = [.topLeft, .topRight, .bottomLeft]
            backgroundColorValue = UIColor(red: 0.93, green: 0.934, blue: 0.95, alpha: 1)
        }
        
        // Remove existing layers and subviews
        subviews.forEach { $0.removeFromSuperview() }
        
        // Shadow view setup
        let shadowView = UIView(frame: self.bounds)
        shadowView.clipsToBounds = false
        self.addSubview(shadowView)
        
        let customPath = UIBezierPath(roundedRect: shadowView.bounds,
                                      byRoundingCorners: customCorners,
                                      cornerRadii: cornerRadii)
        
        // Shadow layers configuration
        let shadowConfigurations = [
            (color: UIColor(red: 0.518, green: 0.545, blue: 0.62, alpha: 0.6), radius: 6, offset: CGSize(width: 6, height: 6)),
            (color: UIColor(red: 0.518, green: 0.545, blue: 0.62, alpha: 0.35), radius: 2, offset: CGSize(width: 1, height: 1.5)),
            (color: UIColor(red: 1, green: 1, blue: 1, alpha: 1), radius: 6, offset: CGSize(width: -6, height: -6)),
            (color: UIColor(red: 1, green: 1, blue: 1, alpha: 1), radius: 2, offset: CGSize(width: -1.2, height: -2.5))
        ]
        
        for config in shadowConfigurations {
            let layer = CALayer()
            layer.shadowPath = customPath.cgPath
            layer.shadowColor = config.color.cgColor
            layer.shadowOpacity = 0.8
            layer.shadowRadius = CGFloat(config.radius)
            layer.shadowOffset = config.offset
            layer.bounds = shadowView.bounds
            layer.position = shadowView.center
            shadowView.layer.addSublayer(layer)
        }
        
        // Shapes view setup
        let shapesView = UIView(frame: self.bounds)
        shapesView.clipsToBounds = true
        self.addSubview(shapesView)
        
        // Background layer
        let backgroundLayer = CALayer()
        backgroundLayer.backgroundColor = backgroundColorValue.cgColor
        backgroundLayer.bounds = shapesView.bounds
        backgroundLayer.position = shapesView.center
        shapesView.layer.addSublayer(backgroundLayer)
        
        // Border layer with custom path
        let borderLayer = CAShapeLayer()
        borderLayer.path = customPath.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = shapesView.bounds
        shapesView.layer.addSublayer(borderLayer)
        
        // Mask the shapes view
        let maskLayer = CAShapeLayer()
        maskLayer.path = customPath.cgPath
        shapesView.layer.mask = maskLayer
    }
    
    func applyShadow(
        backgroundColor: UIColor = .white,
        cornerRadii: CGSize = CGSize(width: 12, height: 12),
        borderColor: UIColor = .white,
        borderWidth: CGFloat = 1.0,
        shadowConfigurations: [(color: UIColor, radius: Int, offset: CGSize)] = [
            (color: UIColor(red: 0.518, green: 0.545, blue: 0.62, alpha: 0.6), radius: 6, offset: CGSize(width: 6, height: 6)),
            (color: UIColor(red: 0.518, green: 0.545, blue: 0.62, alpha: 0.35), radius: 2, offset: CGSize(width: 1, height: 1.5)),
            (color: UIColor(red: 1, green: 1, blue: 1, alpha: 1), radius: 6, offset: CGSize(width: -6, height: -6)),
            (color: UIColor(red: 1, green: 1, blue: 1, alpha: 1), radius: 2, offset: CGSize(width: -1.2, height: -2.5))
        ]
    ) {
        // Define properties based on the cell type
        let customCorners: UIRectCorner
        let backgroundColorValue: UIColor
        
        customCorners = [.topLeft, .bottomRight, .topRight, .bottomLeft]
        backgroundColorValue = backgroundColor
        
        // Remove existing layers and subviews
        subviews.forEach { $0.removeFromSuperview() }
        
        // Shadow view setup
        let shadowView = UIView(frame: self.bounds)
        shadowView.clipsToBounds = false
        self.addSubview(shadowView)
        
        let customPath = UIBezierPath(roundedRect: shadowView.bounds,
                                      byRoundingCorners: customCorners,
                                      cornerRadii: cornerRadii)
                
        for config in shadowConfigurations {
            let layer = CALayer()
            layer.shadowPath = customPath.cgPath
            layer.shadowColor = config.color.cgColor
            layer.shadowOpacity = 1.0
            layer.shadowRadius = CGFloat(config.radius)
            layer.shadowOffset = config.offset
            layer.bounds = shadowView.bounds
            layer.position = shadowView.center
            shadowView.layer.addSublayer(layer)
        }
        
        // Shapes view setup
        let shapesView = UIView(frame: self.bounds)
        shapesView.clipsToBounds = true
        self.addSubview(shapesView)
        
        // Background layer
        let backgroundLayer = CALayer()
        backgroundLayer.backgroundColor = backgroundColorValue.cgColor
        backgroundLayer.bounds = shapesView.bounds
        backgroundLayer.position = shapesView.center
        shapesView.layer.addSublayer(backgroundLayer)
        
        // Border layer with custom path
        let borderLayer = CAShapeLayer()
        borderLayer.path = customPath.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = shapesView.bounds
        shapesView.layer.addSublayer(borderLayer)
        
        // Mask the shapes view
        let maskLayer = CAShapeLayer()
        maskLayer.path = customPath.cgPath
        shapesView.layer.mask = maskLayer
    }
    
    func applyInnerShadow(
        backgroundColor: UIColor = .white,
        cornerRadii: CGSize = CGSize(width: 12, height: 12),
        borderColor: UIColor = .white,
        borderWidth: CGFloat = 1.0
    ) {
        // Define properties
        let customCorners: UIRectCorner = [.topLeft, .bottomRight, .topRight, .bottomLeft]
        
        // Remove existing layers and subviews
        subviews.forEach { $0.removeFromSuperview() }
        
        // Background view setup
        let backgroundView = UIView(frame: self.bounds)
        backgroundView.clipsToBounds = true
        self.addSubview(backgroundView)
        
        // Background layer
        let backgroundLayer = CALayer()
        backgroundLayer.backgroundColor = backgroundColor.cgColor
        backgroundLayer.frame = backgroundView.bounds
        backgroundView.layer.addSublayer(backgroundLayer)
        
        // Inner shadow configurations
        let shadowConfigurations = [
            (color: UIColor(red: 0.518, green: 0.545, blue: 0.62, alpha: 0.6), radius: 3, offset: CGSize(width: 3, height: 3)),
            (color: UIColor(red: 0.518, green: 0.545, blue: 0.62, alpha: 0.35), radius: 2, offset: CGSize(width: 1, height: 1.5)),
            (color: UIColor(red: 1, green: 1, blue: 1, alpha: 1), radius: 3, offset: CGSize(width: -3, height: -3)),
            (color: UIColor(red: 1, green: 1, blue: 1, alpha: 1), radius: 2, offset: CGSize(width: -1.2, height: -2.5))
        ]
        
        // Create the inner shadow layers
        for config in shadowConfigurations {
            let innerShadowLayer = CAShapeLayer()
            
            // Create the inner shadow path
            let outerRect = CGRect(x: -self.bounds.width, y: -self.bounds.height,
                                   width: self.bounds.width * 3, height: self.bounds.height * 3)
            let outerPath = UIBezierPath(rect: outerRect)
            let innerPath = UIBezierPath(roundedRect: self.bounds,
                                         byRoundingCorners: customCorners,
                                         cornerRadii: cornerRadii).reversing()
            outerPath.append(innerPath)
            
            innerShadowLayer.path = outerPath.cgPath
            innerShadowLayer.fillRule = .evenOdd
            innerShadowLayer.fillColor = backgroundColor.cgColor
            innerShadowLayer.shadowColor = config.color.cgColor
            innerShadowLayer.shadowOpacity = 0.7
            innerShadowLayer.shadowRadius = CGFloat(config.radius)
            innerShadowLayer.shadowOffset = config.offset
            
            // Add the inner shadow layer to the background view
            backgroundView.layer.addSublayer(innerShadowLayer)
        }
        
        // Border layer
        let borderLayer = CAShapeLayer()
        let borderPath = UIBezierPath(roundedRect: self.bounds,
                                      byRoundingCorners: customCorners,
                                      cornerRadii: cornerRadii)
        borderLayer.path = borderPath.cgPath
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = borderWidth
        backgroundView.layer.addSublayer(borderLayer)
    }
    
    func applyImageShadow( backgroundColor: UIColor = .clear,
                           cornerRadii: CGSize = CGSize(width: 12, height: 12),
                           borderColor: UIColor = .clear,
                           corners: UIRectCorner = [.topLeft, .bottomRight, .topRight, .bottomLeft],
                           borderWidth: CGFloat = 1.0) {
        // Define properties based on the cell type
        let customCorners: UIRectCorner
        let backgroundColorValue: UIColor
        
        customCorners = corners
        backgroundColorValue = backgroundColor
        
        // Remove existing layers and subviews
        subviews.forEach { $0.removeFromSuperview() }
        
        // Shadow view setup
        let shadowView = UIView(frame: self.bounds)
        shadowView.clipsToBounds = false
        self.addSubview(shadowView)
        
        let customPath = UIBezierPath(roundedRect: shadowView.bounds,
                                      byRoundingCorners: customCorners,
                                      cornerRadii: cornerRadii)
        
        
        let layer = CALayer()
        layer.shadowPath = customPath.cgPath
       // layer.shadowColor = config.color.cgColor
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.bounds = shadowView.bounds
        layer.position = shadowView.center
        shadowView.layer.addSublayer(layer)
        
        // Shapes view setup
        let shapesView = UIView(frame: self.bounds)
        shapesView.clipsToBounds = true
        self.addSubview(shapesView)
        
        // Background layer
        let backgroundLayer = CALayer()
        backgroundLayer.backgroundColor = backgroundColorValue.cgColor
        backgroundLayer.bounds = shapesView.bounds
        backgroundLayer.position = shapesView.center
        shapesView.layer.addSublayer(backgroundLayer)
        
        // Border layer with custom path
        let borderLayer = CAShapeLayer()
        borderLayer.path = customPath.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = shapesView.bounds
        shapesView.layer.addSublayer(borderLayer)

    }
    
}

import UIKit

extension UIView {

    func applyShadow(
        color: UIColor = .black,
        opacity: Float = 0.5,
        radius: CGFloat = 4,
        offset: CGSize = .zero,
        cornerRadius: CGFloat = 0
    ) {
        
        removeShadow()
        
        // Apply the new shadow
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = offset
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        self.layer.masksToBounds = false
    }

    func removeShadow() {
        self.layer.shadowPath = nil
        self.layer.shadowColor = nil
        self.layer.shadowOpacity = 0
        self.layer.shadowRadius = 0
        self.layer.shadowOffset = .zero
    }
}
