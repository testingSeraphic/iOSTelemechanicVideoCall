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
    
    public func navigateToVideoCallScreen(loginName: String,roomId: String, loginUID: String, remoteUID: String, roleType: String, meetingTimer: String, completion: @escaping(Bool) -> Void) {
        
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
               completion(success)
            }
        }
    }
}
