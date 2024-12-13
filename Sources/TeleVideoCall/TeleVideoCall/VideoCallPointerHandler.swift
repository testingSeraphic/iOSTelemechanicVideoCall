//
//  VideoCallPointerHandler.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 05/11/24.
//

import Foundation
import UIKit


extension VideoVC: UIGestureRecognizerDelegate {

    func configurePointer() {
        
        // check if the cursor is already added by using a unique tag
        let cursorTag = 99999
        
        let parentView: UIView?
        
        parentView = userRendererView
        
        guard let parentView = parentView else { return }
        
        // Set the desired width and height
        let cursorWidth: CGFloat = cursorSize
        let cursorHeight: CGFloat = cursorSize
        
        // Calculate the x and y position to center the cursorImageView within the parent view
        let cursorX = (parentView.bounds.width - cursorWidth) / 2
        let cursorY = (parentView.bounds.height - cursorHeight) / 2
    
        
        // Set the frame of cursorImageView
        cursorImageView.frame = CGRect(x: cursorX, y: cursorY, width: cursorWidth, height: cursorHeight)
        
        if parentView.viewWithTag(cursorTag) == nil {
                        
            // set the tag to the cursorImageView
            cursorImageView.tag = cursorTag
            
            // add the cursorImageView to the parent view and bring it to the front
            parentView.addSubview(cursorImageView)
        }
        
        parentView.bringSubviewToFront(cursorImageView)
        addGestureOn()
    }
    
    func addGestureOn() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        let targetView: UIView = userRendererView ?? UIView()
        targetView.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let targetView = userRendererView else { return }
        let touchLocation = gesture.location(in: targetView)
        
        // Calculate the new center position of the cursor
        var newCenterX = touchLocation.x
        var newCenterY = touchLocation.y
        
        // Define the boundaries to prevent the cursor from going outside the target view
        let cursorHalfWidth = cursorImageView.bounds.width / 2
        let cursorHalfHeight = cursorImageView.bounds.height / 2
        
        // Clamp X position
        newCenterX = max(cursorHalfWidth, min(newCenterX, targetView.bounds.width - cursorHalfWidth))
        
        // Clamp Y position
        newCenterY = max(cursorHalfHeight, min(newCenterY, targetView.bounds.height - cursorHalfHeight))
        
        // Set the new center for cursorImageView
        cursorImageView.center = CGPoint(x: newCenterX, y: newCenterY)
        
        // Save local cursor points
        self.cursorViewOrigin = cursorImageView.frame.origin
        
        // Send cursor points
        if let encodedData = self.encodePointerData(viewOrigin: cursorImageView.frame.origin,
                                                    parentSize: targetView.frame.size) {
            self.meetingModel?.sendPointerData(encodedData)
        }
    }
    
    func encodePointerData(viewOrigin: CGPoint, parentSize: CGSize) -> Data? {
        
        // get the screen scale factor
        let screenScale = 1.0
        
        // convert points to pixels
        let pixelOrigin = CGPoint(x: viewOrigin.x * screenScale, y: viewOrigin.y * screenScale)
        let pixelSize = CGSize(width: parentSize.width * screenScale, height: parentSize.height * screenScale)
        
        let cursorPixel = "cursorPixel[\(pixelOrigin.x),\(pixelOrigin.y),\(pixelSize.width),\(pixelSize.height)]"
        
        // convert the cursorPixels string into Data using ASCII encoding
        let data = cursorPixel.data(using: .ascii)
        
        return data
    }
    
    func decodePointerData(jsonString: String) -> (viewOrigin: CGPoint?, parentSize: CGSize?)? {
        // Check if the jsonString starts with "cursorPoints["
        guard jsonString.hasPrefix("cursorPixel["),
              let startIndex = jsonString.firstIndex(of: "["),
              let endIndex = jsonString.lastIndex(of: "]") else {
            print("Invalid format")
            return (viewOrigin: nil, parentSize: nil)
        }
        
        // Extract the content between the brackets
        let valuesString = jsonString[startIndex...].dropFirst().dropLast()
        
        // Split the content by commas to get the x, y, width, and height values
        let components = valuesString.split(separator: ",").compactMap { Double($0) }
        
        guard components.count == 4 else {
            print("Invalid number of components")
            return (viewOrigin: nil, parentSize: nil)
        }
        
        // convert values from pixels to points
        let screenScale = 1.0
        
        let viewOrigin = CGPoint(x: components[0] / screenScale, y: components[1] / screenScale)
        let parentSize = CGSize(width: components[2] / screenScale, height: components[3] / screenScale)
                
        return (viewOrigin: viewOrigin, parentSize: parentSize)
    }
    
    // sync both views
    func syncViewPosition(
        firstViewOrigin: CGPoint,
        firstParentSize: CGSize,
        secondParentSize: CGSize
    ) -> CGPoint {
        
        let firstViewSize = CGSize(width: cursorSize, height: cursorSize)
        let secondViewSize = CGSize(width: cursorSize, height: cursorSize)
        
        // Calculate the relative position as a percentage
        let relativeX = firstViewOrigin.x / (firstParentSize.width - firstViewSize.width)
        let relativeY = firstViewOrigin.y / (firstParentSize.height - firstViewSize.height)
        
        // Calculate the new position for the second view within its parent view
        let secondViewPositionX = relativeX * (secondParentSize.width - secondViewSize.width)
        let secondViewPositionY = relativeY * (secondParentSize.height - secondViewSize.height)
        
        // Return the new CGPoint
        return CGPoint(x: secondViewPositionX, y: secondViewPositionY)
    }

    func removePointer() {
        cursorImageView.removeFromSuperview()
    }

}

