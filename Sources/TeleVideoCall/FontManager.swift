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
        
        // Debug: Print the bundle path
        print("FontLoader: Bundle path - \(bundle.bundlePath)")
        
        // Debug: Check if the fonts folder exists
        if let fontFolderPath = bundle.path(forResource: "Font/ttf", ofType: nil) {
            print("FontLoader: Fonts folder found at \(fontFolderPath)")
        } else {
            print("FontLoader: Fonts folder not found.")
        }
        
        // Retrieve font URLs
        guard let fontURLs = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: "Font/ttf") else {
            print("FontLoader: No .ttf files found in the Fonts/ttf folder.")
            return
        }
        
        print("FontLoader: Found \(fontURLs.count) font(s) in the bundle.")
        
        for fontURL in fontURLs {
            print("FontLoader: Attempting to load font at \(fontURL)")
            
            // Attempt to register the font
            var error: Unmanaged<CFError>?
            if CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error) == false {
                if let error = error?.takeRetainedValue() {
                    print("FontLoader: Failed to load font \(fontURL.lastPathComponent). Error: \(error.localizedDescription)")
                } else {
                    print("FontLoader: Failed to load font \(fontURL.lastPathComponent). Unknown error.")
                }
            } else {
                print("FontLoader: Successfully loaded font \(fontURL.lastPathComponent).")
            }
        }
    }
}
