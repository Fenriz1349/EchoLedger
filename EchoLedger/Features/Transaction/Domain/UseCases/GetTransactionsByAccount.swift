//
//  GetTransactionsByAccount.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/06/2026.
//

import Foundation

/// Fetches every transaction for a user that allocates a split to the given account.
/// Mirrors GetAccountsWithInstitution: composes the GetTransactions use case rather than
/// querying the repository directly.
final class GetTransactionsByAccount {

    private let getTransactions: GetTransactions

    /// - Parameter getTransactions: UseCase fetching all of the user's transactions.
    init(getTransactions: GetTransactions) {
        self.getTransactions = getTransactions
    }

    /// - Parameters:
    ///   - userId: The identifier of the current user.
    ///   - accountId: The account whose transactions are requested.
    /// - Returns: Every transaction holding at least one split on the account.
    func execute(for userId: UUID, accountId: UUID) async throws -> [Transaction] {
        let transactions = try await getTransactions.execute(for: userId)
        return transactions.filter { $0.belongs(to: accountId) }
    }
}
