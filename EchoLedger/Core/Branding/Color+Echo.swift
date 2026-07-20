//
//  Color+Echo.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/06/2026.
//

import SwiftUI

extension Color {

    /// Brand-tinted screen background (lavender in light, dark purple in dark).
    static let echoBackground = Color("BackgroundColor")

    /// Card/row surface that sits on the brand background.
    static let echoCard = Color("CardBackgroundColor")

    /// Darker brand accent, used in gradients.
    static let echoAccentHard = Color("AccentHard")

    /// Lighter brand accent, used in gradients.
    static let echoAccentSoft = Color("AccentSoft")
}
