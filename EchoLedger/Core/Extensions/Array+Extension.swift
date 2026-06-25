//
//  Array+Extension.swift
//  EchoLedger
//
//  Created by Julien Cotte on 25/06/2026.
//

import Foundation

extension Array {
    subscript(safe index: Int, default defaultValue: Element) -> Element {
        guard indices.contains(index) else { return defaultValue }
        return self[index]
    }
}
