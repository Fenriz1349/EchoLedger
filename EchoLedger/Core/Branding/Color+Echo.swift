//
//  Color+Echo.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/06/2026.
//

import SwiftUI

extension Color {

    /// Brand-tinted screen background (lavender in light, dark purple in dark).
    static let echoBackground = Color(.backgroundColor)

    /// Card/row surface that sits on the brand background.
    static let echoCard = Color(.cardBackgroundColor)

    /// Darker brand accent, used in gradients.
    static let echoAccentHard = Color(.accentHard)

    /// Lighter brand accent, used in gradients.
    static let echoAccentSoft = Color(.accentSoft)
}
