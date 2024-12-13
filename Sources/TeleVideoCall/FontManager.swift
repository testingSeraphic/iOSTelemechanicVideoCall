//
//  File.swift
//  
//
//  Created by Apple on 12/11/24.
//


import UIKit
import CoreText

public struct Appearance {
    /// Configures all the UI of the package
    public static func configurePackageUI() {
        loadPackageFonts()
    }

    private static func loadPackageFonts() {
        // List of custom font filenames
        let fontNames = [
            "OverusedGrotesk-Black.ttf",
            "OverusedGrotesk-BlackItalic.ttf",
            "OverusedGrotesk-Bold.ttf",
            "OverusedGrotesk-BoldItalic.ttf",
            "OverusedGrotesk-Book.ttf",
            "OverusedGrotesk-BookItalic.ttf",
            "OverusedGrotesk-ExtraBold.ttf",
            "OverusedGrotesk-ExtraBoldItalic.ttf",
            "OverusedGrotesk-Italic.ttf",
            "OverusedGrotesk-Light.ttf",
            "OverusedGrotesk-LightItalic.ttf",
            "OverusedGrotesk-Medium.ttf",
            "OverusedGrotesk-MediumItalic.ttf",
            "OverusedGrotesk-Roman.ttf",
            "OverusedGrotesk-SemiBold.ttf",
            "OverusedGrotesk-SemiBoldItalic.ttf"
        ]

        // Register each font
        fontNames.forEach { registerFont(fileName: $0) }
    }

    private static func registerFont(fileName: String) {
        guard let fontRef = loadFont(named: fileName) else {
            print("*** ERROR: Font \(fileName) could not be loaded. ***")
            return
        }

        var errorRef: Unmanaged<CFError>? = nil
        if !CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) {
            if let error = errorRef?.takeUnretainedValue() {
                print("*** ERROR: Failed to register font \(fileName): \(error.localizedDescription) ***")
            } else {
                print("*** ERROR: Unknown error occurred while registering font \(fileName). ***")
            }
        } else {
            print("Successfully registered font: \(fileName)")
        }
    }

    private static func loadFont(named fileName: String) -> CGFont? {
        // Access the font file from the package's module bundle
        guard let url = Bundle.module.url(forResource: fileName, withExtension: nil) else {
            print("*** ERROR: Font file \(fileName) not found in the bundle. ***")
            return nil
        }

        // Create a `CGFont` object from the font data
        guard let fontData = try? Data(contentsOf: url) as CFData,
              let dataProvider = CGDataProvider(data: fontData),
              let fontRef = CGFont(dataProvider) else {
            print("*** ERROR: Unable to create CGFont from file \(fileName). ***")
            return nil
        }

        return fontRef
    }
}
