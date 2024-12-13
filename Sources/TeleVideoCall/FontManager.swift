//
//  File.swift
//  
//
//  Created by Apple on 12/11/24.
//


import UIKit
import CoreText

import UIKit
import CoreText

public class FontLoader {
    public static func registerFonts() {
        let bundle = Bundle.module
        guard let fontURLs = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: "Font/ttf") else {
            print("No fonts found in the bundle.")
            return
        }
        
        for fontURL in fontURLs {
            var error: Unmanaged<CFError>?
            if CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error) == false {
                print("Failed to load font: \(fontURL.lastPathComponent), error: \(String(describing: error))")
            } else {
                print("Font loaded successfully: \(fontURL.lastPathComponent)")
            }
        }
    }
}
