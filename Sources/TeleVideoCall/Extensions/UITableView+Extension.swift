//
//  UITableView+Extension.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 25/11/24.
//

import Foundation
import UIKit

extension UITableView {
    func scrollToRow(
        at indexPath: IndexPath,
        position: UITableView.ScrollPosition,
        animated: Bool,
        completion: @escaping () -> Void
    ) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion()
        }
        self.scrollToRow(at: indexPath, at: position, animated: animated)
        CATransaction.commit()
    }
}
