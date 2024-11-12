//
//  LogEntry.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 23/10/24.
//

import Foundation
import AmazonChimeSDK

struct LogEntry: Codable {
    var sequenceNumber: Int
    var message: String
    var timestampMs: Int64
    var logLevel: String
}
