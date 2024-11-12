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
        let fontNames = ["OverusedGrotesk-SemiBold"] // Replace with your font file names

        for fontName in fontNames {
            if let fontURL = Bundle.module.url(forResource: fontName, withExtension: "ttf"), // Adjust extension if needed
               let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
               let font = CGFont(fontDataProvider) {
                var error: Unmanaged<CFError>?
                if !CTFontManagerRegisterGraphicsFont(font, &error) {
                    print("Error registering font \(fontName): \(String(describing: error))")
                }
            } else {
                print("Failed to load font \(fontName).")
            }
        }
    }
}
