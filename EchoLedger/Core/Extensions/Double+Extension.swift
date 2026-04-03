//
//  Double+Extension.swift
//  EchoLedger
//
//  Created by Julien Cotte on 03/04/2026.
//

import Foundation

extension Double {

    var toEuro: String {
        String(format: "%.2f €", self)
    }
}
