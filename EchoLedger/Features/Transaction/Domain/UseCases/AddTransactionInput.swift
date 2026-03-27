//
//  AddTransactionInput.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation

/// Encapsulates all parameters required to create a new transaction.
struct AddTransactionInput {
    let userId: UUID
    let label: String
    let date: Date
    let totalAmount: Double
    let note: String?
    let isExpense: Bool
    let category: TransactionCategory
    let splits: [TransactionSplit]
}
