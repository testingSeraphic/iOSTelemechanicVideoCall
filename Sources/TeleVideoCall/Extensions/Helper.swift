//
//  Date+Extensions.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 18/11/24.
//

import Foundation

class Helper {
  
    static func formatTimestamp(_ timestamp: Int, toFormat format: String = "h:mm a", localeIdentifier: String = "en_US_POSIX") -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: localeIdentifier)
        return dateFormatter.string(from: date)
    }
    
    static func formatSize(bytes: Double?) -> String {
        guard let bytes = bytes else { return "" }
        if bytes < 1024 {
            return String(format: "%.2f bytes", bytes)
        } else if bytes < 1024 * 1024 {
            return String(format: "%.2f KB", bytes / 1024)
        } else if bytes < 1024 * 1024 * 1024 {
            return String(format: "%.2f MB", bytes / (1024 * 1024))
        } else {
            return String(format: "%.2f GB", bytes / (1024 * 1024 * 1024))
        }
    }
}

