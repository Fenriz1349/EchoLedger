//
//  GetAccountBalance.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/03/2026.
//

import Foundation

/// Computes the current balance of an account by aggregating its transaction splits.
/// This is the only UseCase that depends on both AccountProviding and TransactionProviding.
final class GetAccountBalance {

    // MARK: Dependencies
    private let accountRepository: AccountProviding
    private let transactionRepository: TransactionProviding

    // MARK: Init
    /// - Parameters:
    ///   - accountRepository: The data contract for account persistence.
    ///   - transactionRepository: The data contract for transaction persistence.
    init(accountRepository: AccountProviding, transactionRepository: TransactionProviding) {
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
    }

    // MARK: Execute
    /// Computes the balance of a given account from all its associated transaction splits.
    /// Expenses are subtracted, income is added.
    /// - Parameters:
    ///   - accountId: The identifier of the account.
    ///   - userId: The identifier of the user owning the transactions.
    /// - Returns: The computed balance as a Decimal.
    /// - Throws: `AccountError.notFound` if the account does not exist.
    func execute(accountId: UUID, userId: UUID) async throws -> Decimal {
        _ = try await accountRepository.fetch(by: accountId)
        let transactions = try await transactionRepository.fetchAll(for: userId)

        return transactions.reduce(Decimal(0)) { balance, transaction in
            let splitAmount = transaction.splits
                .filter { $0.accountId == accountId }
                .map(\.amount)
                .reduce(Decimal(0), +)

            return transaction.isExpense ? balance - splitAmount : balance + splitAmount
        }
    }
}
