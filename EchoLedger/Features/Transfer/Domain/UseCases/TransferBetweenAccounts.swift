//
//  TransferBetweenAccounts.swift
//  EchoLedger
//
//  Created by Julien Cotte on 22/05/2026.
//

import Foundation

/// Creates an internal transfer between two accounts.
/// Produces two linked transactions:
///   - An expense on the source account
///   - An income on the destination account
/// Both are tagged `.transfer` and excluded from charts and reports.
final class TransferBetweenAccounts {

    private let repository: TransactionProviding

    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    /// Executes the transfer by persisting both transactions.
    /// - Parameter input: The transfer parameters.
    /// - Throws: `TransactionError` if either save fails.
    func execute(_ input: TransferInput) async throws {
        let expense = Transaction(
            userId: input.userId,
            label: input.label,
            date: input.date,
            totalAmount: input.amount,
            isExpense: true,
            category: .transfer,
            splits: [TransactionSplit(accountId: input.sourceAccountId, amount: input.amount)],
            updatedAt: Date()
        )
        let income = Transaction(
            userId: input.userId,
            label: input.label,
            date: input.date,
            totalAmount: input.amount,
            isExpense: false,
            category: .transfer,
            splits: [TransactionSplit(accountId: input.destinationAccountId, amount: input.amount)],
            updatedAt: Date()
        )
        try await repository.save(expense)
        try await repository.save(income)
    }
}
