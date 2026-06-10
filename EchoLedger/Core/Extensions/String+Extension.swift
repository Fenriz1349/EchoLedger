//
//  String+Extension.swift
//  EchoLedger
//
//  Created by Julien Cotte on 03/04/2026.
//

import Foundation

extension String {

    /// Converts a string to a Double, accepting both comma and dot as decimal separators.
    /// - Returns: The parsed Double, or 0 if the string is not a valid number.
    var toDouble: Double {
        Double(self.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    /// Keeps only the characters allowed in an amount entry: digits and a single decimal separator.
    /// Drops any character that isn't a digit, and any separator (`.` or `,`) beyond the first one.
    /// Used to filter out anything a hardware keyboard might insert that `.decimalPad` would block.
    var numericOnly: String {
        var hasSeparator = false
        return filter { character in
            if character.isNumber { return true }
            if (character == "." || character == ",") && !hasSeparator {
                hasSeparator = true
                return true
            }
            return false
        }
    }
}
