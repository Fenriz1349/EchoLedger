//
//  Double+Extension.swift
//  EchoLedger
//
//  Created by Julien Cotte on 03/04/2026.
//

import Foundation

extension Double {

    /// Formats the value as a euro currency string with two decimal places (e.g. "12.50 €").
    var toEuro: String {
        String(format: "%.2f €", self)
    }
}
