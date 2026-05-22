//
//  TransactionListItem.swift
//  EchoLedger
//
//  Created by Julien Cotte on 22/05/2026.
//

import Foundation

/// Represents a single row item in a transaction list.
/// A `.transfer` groups the matching expense and income legs of an internal transfer.
enum TransactionListItem: Identifiable {

    case single(Transaction)
    case transfer(Transfer)

    var id: UUID {
        switch self {
        case .single(let transaction): return transaction.id
        case .transfer(let transfer): return transfer.id
        }
    }

    /// Groups a flat array of transactions into display items, newest first.
    /// Transfer pairs (same label, same amount, same day, opposite `isExpense`) are merged into a `.transfer` item.
    /// Unpaired transfer transactions fall back to `.single`.
    static func group(_ transactions: [Transaction]) -> [TransactionListItem] {
        var result: [TransactionListItem] = []
        var usedIds: Set<UUID> = []
        let sorted = transactions.sorted { $0.date > $1.date }

        for transaction in sorted {
            guard !usedIds.contains(transaction.id) else { continue }

            if transaction.category == .transfer,
               let pair = sorted.first(where: {
                   !usedIds.contains($0.id) &&
                   $0.id != transaction.id &&
                   $0.category == .transfer &&
                   $0.totalAmount == transaction.totalAmount &&
                   $0.label == transaction.label &&
                   $0.isExpense != transaction.isExpense &&
                   Calendar.current.isDate($0.date, inSameDayAs: transaction.date)
               }) {
                let expense = transaction.isExpense ? transaction : pair
                let income = transaction.isExpense ? pair : transaction
                result.append(.transfer(Transfer(source: expense, destination: income)))
                usedIds.insert(transaction.id)
                usedIds.insert(pair.id)
            } else {
                result.append(.single(transaction))
                usedIds.insert(transaction.id)
            }
        }
        return result
    }
}
