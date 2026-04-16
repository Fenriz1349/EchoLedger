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
    
    /// Converts a Firebase Auth uid string into a stable UUID.
    /// Pads or truncates the string to fit the 32-character UUID hex format.
    /// - Returns: A stable UUID derived from the Firebase Auth uid.
    var toUUID: UUID {
        let hex = self.replacingOccurrences(of: "-", with: "")
        let padded = hex.padding(toLength: 32, withPad: "0", startingAt: 0)
        let uuidString = [
            padded.prefix(8),
            padded.dropFirst(8).prefix(4),
            padded.dropFirst(12).prefix(4),
            padded.dropFirst(16).prefix(4),
            padded.dropFirst(20).prefix(12)
        ].joined(separator: "-")
        return UUID(uuidString: uuidString) ?? UUID()
    }
}
