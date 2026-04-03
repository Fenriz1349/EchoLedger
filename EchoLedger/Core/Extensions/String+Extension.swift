//
//  String+Extension.swift
//  EchoLedger
//
//  Created by Julien Cotte on 03/04/2026.
//

import Foundation

extension String {

    var toDouble: Double? {
        Double(self.replacingOccurrences(of: ",", with: "."))
    }
}
