//
//  LogRequestBody.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 23/10/24.
//

import Foundation

struct LogRequestBody: Codable {
    var meetingId: String
    var attendeeId: String
    var appName: String
    var logs: [LogEntry]
}
