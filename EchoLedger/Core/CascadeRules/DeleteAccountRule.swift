//
//  DeleteAccountRule.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/06/2026.
//

import Foundation

/// Orchestrates the full deletion of an account: cleans up the transactions allocated to it,
/// then deletes the account record. Lives above the features so each feature use case stays
/// single-aggregate.
///
/// For each transaction holding a split on the account:
///   - if it is the transaction's only split → the whole transaction is deleted (record + attachment);
///   - otherwise → only that split is removed and the total is recomputed (the transaction is kept).
///
/// A transfer is two independent single-split transactions, so deleting one of its accounts simply
/// removes that leg and leaves the other intact — the transfer is never reversed.
final class DeleteAccountRule {

    private let getTransactionsByAccount: GetTransactionsByAccount
    private let deleteTransaction: DeleteTransaction
    private let updateTransaction: UpdateTransaction
    private let deleteAccount: DeleteAccount
    private let userId: UUID

    init(getTransactionsByAccount: GetTransactionsByAccount,
         deleteTransaction: DeleteTransaction,
         updateTransaction: UpdateTransaction,
         deleteAccount: DeleteAccount,
         userId: UUID) {
        self.getTransactionsByAccount = getTransactionsByAccount
        self.deleteTransaction = deleteTransaction
        self.updateTransaction = updateTransaction
        self.deleteAccount = deleteAccount
        self.userId = userId
    }

    /// - Parameter id: The unique identifier of the account to delete.
    func execute(id: UUID) async throws {
        let transactions = try await getTransactionsByAccount.execute(for: userId, accountId: id)
        for transaction in transactions {
            let remainingSplits = transaction.splits.filter { $0.accountId != id }
            if remainingSplits.isEmpty {
                try await deleteTransaction.execute(id: transaction.id)
            } else {
                try await updateTransaction.execute(detach(transaction, keeping: remainingSplits))
            }
        }
        try await deleteAccount.execute(id: id)
    }

    /// Rebuilds the update input after dropping one account's split, recomputing the total so the
    /// splits-sum invariant still holds.
    private func detach(_ transaction: Transaction, keeping remainingSplits: [TransactionSplit]) -> UpdateTransactionInput {
        UpdateTransactionInput(
            id: transaction.id,
            userId: transaction.userId,
            label: transaction.label,
            date: transaction.date,
            totalAmount: remainingSplits.map(\.amount).reduce(0, +),
            note: transaction.note,
            isExpense: transaction.isExpense,
            category: transaction.category,
            splits: remainingSplits,
            attachmentURL: transaction.attachmentURL,
            attachmentContentType: transaction.attachmentContentType
        )
    }
}
