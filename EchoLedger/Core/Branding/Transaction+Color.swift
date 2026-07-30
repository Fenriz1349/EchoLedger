//
//  Transaction+Color.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/07/2026.
//

import SwiftUI

extension Transaction {

    /// Color to display in Transactions lists
    var color: Color {
        if self.category == .initialBalance && self.isExpense {
            return .red
        } else if !self.isExpense {
            return .green
        } else {
            return .primary
        }
    }
}
