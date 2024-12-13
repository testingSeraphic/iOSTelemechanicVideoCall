//
//  UIButton+Extensions.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 28/10/24.
//

import Foundation
import UIKit

extension UIView {
    func applyButtonShadow() {
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.masksToBounds = false
    }
}
