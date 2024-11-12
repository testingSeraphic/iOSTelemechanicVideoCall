//
//  VideoCallIntiatorVC.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 23/10/24.
//

import UIKit
import AmazonChimeSDK

public class VideoCallIntiatorVC: UIViewController {
    
    @IBOutlet weak var meetingIdTextField: UITextField!
    @IBOutlet weak var userTextField: UITextField!
    
    let debugSettingsModel: DebugSettingsModel = DebugSettingsModel()
    
    var activityIndicator: UIActivityIndicatorView?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator?.center = view.center
        activityIndicator?.hidesWhenStopped = true
        
//        if let activityIndicator = activityIndicator {
//            view.addSubview(activityIndicator)
//        }
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // activityIndicator?.startAnimating()
        
        
    }

    @IBAction func startVideoCall(_ sender: UIButton) {
        
        // Proceed with the meeting
        MeetingModule.shared().prepareMeeting(meetingId: self.meetingIdTextField.text ?? "",
                                              selfName: self.userTextField.text ?? "",
                                              overriddenEndpoint: self.debugSettingsModel.endpointUrl,
                                              primaryExternalMeetingId: self.debugSettingsModel.primaryExternalMeetingId) { success in
            DispatchQueue.main.async {
                if !success {
                    // Handle failure to prepare the meeting
                    let alert = UIAlertController(title: "Error", message: "Please enter different Meeting ID", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        
    }
    
//    func startVideoCall(meetingId: String = "", name: String = "") {
//        
//        // Proceed with the meeting
//        MeetingModule.shared().prepareMeeting(meetingId: meetingId,
//                                              selfName: name,
//                                              overriddenEndpoint: self.debugSettingsModel.endpointUrl,
//                                              primaryExternalMeetingId: self.debugSettingsModel.primaryExternalMeetingId) { success in
//            DispatchQueue.main.async {
//                self.activityIndicator?.stopAnimating()
//                if !success {
//                    // Handle failure to prepare the meeting
//                    let alert = UIAlertController(title: "Error", message: "Please enter different Meeting ID", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                }
//            }
//        }
//    }
}


