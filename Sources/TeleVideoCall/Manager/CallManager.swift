//
//  CallManager.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 12/11/24.
//

import Foundation

public class CallManager {
    let debugSettingsModel: DebugSettingsModel = DebugSettingsModel()
    
 
    
    public func navigateToVideoCallScreen(participantName: String,channelName: String) {
        
        MeetingModule.shared().prepareMeeting(meetingId: channelName,
                                              selfName: participantName,
                                              overriddenEndpoint: self.debugSettingsModel.endpointUrl,
                                              primaryExternalMeetingId: self.debugSettingsModel.primaryExternalMeetingId) { success in
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
