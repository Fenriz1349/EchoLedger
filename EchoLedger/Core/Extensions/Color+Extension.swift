//
//  Color+Extension.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/04/2026.
//

import SwiftUI
import CustomTextFields

extension Color {

    /// Creates a Color from a hex string (e.g. "#8B50CC" or "8B50CC").
    /// - Parameter hex: The hex color string.
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let red = Double((int >> 16) & 0xFF) / 255
        let green = Double((int >> 8)  & 0xFF) / 255
        let blue = Double(int         & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }

    /// Creates a Color that adapts to light and dark mode.
    /// - Parameters:
    ///   - light: Color for light mode.
    ///   - dark: Color for dark mode.
    init(light: Color, dark: Color) {
        self.init(UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
    }
}

extension ValidationColors {

    /// EchoLedger brand colors for text field validation states.
    static let echo = ValidationColors(
        neutral: Color(.systemGray4),
        valid: .green,
        invalid: .red,
        focused: .accent
    )
}
