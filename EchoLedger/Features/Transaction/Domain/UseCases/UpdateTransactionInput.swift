//
//  UpdateTransactionInput.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation

/// Encapsulates all parameters required to update an existing transaction.
struct UpdateTransactionInput {
    let id: UUID
    let userId: UUID
    let label: String
    let date: Date
    let totalAmount: Double
    let note: String?
    let isExpense: Bool
    let category: TransactionCategory
    let splits: [TransactionSplit]
}
