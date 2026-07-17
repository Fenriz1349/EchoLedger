//
//  GetLastUsedAccount.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/07/2026.
//

import Foundation

/// Fetches the most recent transaction for a user.
/// Mirrors GetTransactionsByAccount: composes GetTransactions rather than querying the repository.
final class GetLastUsedAccount {

    private let getTransactions: GetTransactions

    /// - Parameter getTransactions: UseCase fetching all of the user's transactions.
    init(getTransactions: GetTransactions) {
        self.getTransactions = getTransactions
    }

    /// - Parameter userId: The identifier of the current user.
    /// - Returns: The most recent transaction, or nil if the user has none yet.
    func execute(for userId: UUID) async throws -> Transaction? {
        try await getTransactions.execute(for: userId).first
    }
}
