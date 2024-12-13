//
//  CallManager.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 12/11/24.
//

import Foundation

public class CallManager {
    
    public static let shared = CallManager()
    let debugSettingsModel: DebugSettingsModel = DebugSettingsModel()
    
    private init() {
    }
    
    func navigateToVideoCallScreen(loginName: String,roomId: String, loginUID: String, remoteUID: String, roleType: String, meetingTimer: String) {
        
        MeetingModule.shared().prepareMeeting(meetingId: roomId,
                                              selfName: loginName,
                                              overriddenEndpoint: self.debugSettingsModel.endpointUrl,
                                              primaryExternalMeetingId: self.debugSettingsModel.primaryExternalMeetingId,
                                              loginUID: loginUID,
                                              remoteUID: remoteUID,
                                              roleType: roleType,
                                              meetingTimer: meetingTimer,
                                              loginUserName: loginName
        ) { success in
            DispatchQueue.main.async {
                if !success {
                    // Handle failure to prepare the meeting
//                    let alert = UIAlertController(title: "Error", message: "Please enter different Meeting ID", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
