//
//  MeetingPresenter.swift
//  AmazonChimeSDKDemo
//
//  Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

class MeetingPresenter {
    private let mainStoryboard = UIStoryboard(name: "TelemechanicVideoMain", bundle: Bundle.module)
    private var activeMeetingViewController: UIViewController?

    var rootViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }

    func showMeetingView(meetingModel: MeetingModel, completion: @escaping (Bool) -> Void) {
        
        guard let rootViewController = self.rootViewController else {
            print("RootVC=",rootViewController)
     
            completion(false)
            return
        }
        
        guard let meetingViewController = mainStoryboard.instantiateViewController(withIdentifier: "VideoVC")
                as? VideoVC else {
            completion(false)
            return
        }
       
        print("meetingViewController=",meetingViewController)
        meetingViewController.modalPresentationStyle = .fullScreen
        meetingViewController.meetingModel = meetingModel
        rootViewController.present(meetingViewController, animated: true) {
            self.activeMeetingViewController = meetingViewController
            completion(true)
        }
    }

    func dismissActiveMeetingView(completion: @escaping () -> Void) {
        guard let activeMeetingViewController = activeMeetingViewController else {
            completion()
            return
        }
        activeMeetingViewController.dismiss(animated: true) {
            self.activeMeetingViewController = nil
            completion()
        }
    }

    func showDeviceSelectionView(meetingModel: MeetingModel, completion: @escaping (Bool) -> Void) {
//        guard let deviceSelectionVC = mainStoryboard.instantiateViewController(withIdentifier: "deviceSelection")
//            as? DeviceSelectionViewController, let rootViewController = self.rootViewController else {
//            completion(false)
//            return
//        }
//        deviceSelectionVC.modalPresentationStyle = .fullScreen
//        deviceSelectionVC.model = meetingModel.deviceSelectionModel
//        rootViewController.present(deviceSelectionVC, animated: true) {
//            self.activeMeetingViewController = deviceSelectionVC
//            completion(true)
//        }
        
            completion(true)
    }
}
