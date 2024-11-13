//
//  File.swift
//  
//
//  Created by Apple on 12/11/24.
//


import UIKit
import CoreText

public struct FontManager {
    public static func initializeFonts() {
        // Find all .ttf font files in the Font/ttf folder
        if let fontURLs = Bundle.module.urls(forResourcesWithExtension: "ttf", subdirectory: "Font/ttf") {
            print("FontURLs==",fontURLs)
            print("FontURLsCount==",fontURLs.count)
            for fontURL in fontURLs {
                if let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
                   let font = CGFont(fontDataProvider) {
                    var error: Unmanaged<CFError>?
                    if !CTFontManagerRegisterGraphicsFont(font, &error) {
                        print("Error registering font \(fontURL.lastPathComponent): \(String(describing: error))")
                    } else {
                        print("Successfully registered font: \(fontURL.lastPathComponent)")
                    }
                } else {
                    print("Failed to load font at \(fontURL.lastPathComponent).")
                }
            }
        } else {
            print("No fonts found in the specified directory.")
        }
    }
}
