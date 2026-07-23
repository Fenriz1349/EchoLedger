//
//  Array+Extension.swift
//  EchoLedger
//
//  Created by Julien Cotte on 25/06/2026.
//

import Foundation

extension Array {
    /// Returns the element at `index`, or `defaultValue` when `index` is out of bounds.
    subscript(safe index: Int, default defaultValue: Element) -> Element {
        guard indices.contains(index) else { return defaultValue }
        return self[index]
    }
}
