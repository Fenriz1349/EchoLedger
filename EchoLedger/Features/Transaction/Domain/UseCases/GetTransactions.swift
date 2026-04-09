//
//  GetTransactions.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Retrieves all transactions belonging to a given user.
final class GetTransactions {

    private let repository: TransactionProviding

    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    /// Fetches all transactions for a specific user, ordered by date descending.
    /// - Parameter userId: The identifier of the user.
    /// - Returns: An array of transactions belonging to the user.
    /// - Throws: `TransactionError` if the fetch fails.
    func execute(for userId: UUID) async throws -> [Transaction] {
        try await repository.fetchAll(for: userId)
    }
}
