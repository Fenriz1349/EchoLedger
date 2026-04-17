//
//  String+Extension.swift
//  EchoLedger
//
//  Created by Julien Cotte on 03/04/2026.
//

import Foundation

extension String {

    /// Converts a string to a Double, accepting both comma and dot as decimal separators.
    /// - Returns: The parsed Double, or nil if the string is not a valid number.
    var toDouble: Double? {
        Double(self.replacingOccurrences(of: ",", with: "."))
    }
}
