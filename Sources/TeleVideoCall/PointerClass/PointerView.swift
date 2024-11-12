//
//  PointerView.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 05/11/24.
//

import Foundation
import UIKit

class PointerView: UIView {
    private var points: [CGPoint] = []

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(5.0)

        for (index, point) in points.enumerated() {
            if index == 0 {
                context.move(to: point)
            } else {
                context.addLine(to: point)
            }
        }
        context.strokePath()
    }

    func addPoint(_ point: CGPoint) {
        points.append(point)
        setNeedsDisplay()
    }

    func clear() {
        points.removeAll()
        setNeedsDisplay()
    }
}
