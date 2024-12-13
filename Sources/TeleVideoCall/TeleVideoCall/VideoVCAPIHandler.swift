//
//  VideoVCAPIHandler.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 21/11/24.
//

import Foundation


extension VideoVC {
    
    func timeExtensionAPIRequest() {
        guard let meetingModel = meetingModel else { return }
        
        let urlString = "https://api.tele-mechanic.dev.seraphic.io/api/v1/appointment/accept-overtime-request"
        let payload: [String: Any] = [
            "appointmentId": "673ecd81f3772d18999121ca"
        ]
        
        print("===========timeExtensionAPIRequest==========")
        print(urlString)
        print(payload)
        
        // Call the common POST request method
        APIClient.postRequest(urlString: urlString, payload: payload) { result in
            switch result {
            case .success(let response):
                print("Response JSON: \(response)")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
