//
//  Double+Extension.swift
//  EchoLedger
//
//  Created by Julien Cotte on 03/04/2026.
//

import SwiftUI

extension Double {

    /// Formats the value as a euro currency string with two decimal places (e.g. "12.50 €").
    var toEuro: String {
        String(format: "%.2f €", self)
    }

    /// Green when positive (including zero), red when negative. For amounts/balances colored by sign.
    var balanceColor: Color {
        self >= 0 ? .green : .red
    }
}
