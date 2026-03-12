//
//  GetTransactions.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

// MARK: - GetTransactions
/// Retrieves all transactions associated with a given account.
final class GetTransactions {

    // MARK: Dependencies
    private let repository: TransactionRepositoryProtocol

    // MARK: Init
    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: Execute
    /// Fetches all transactions for a specific account, ordered by date descending.
    /// - Parameter accountId: The identifier of the account.
    /// - Returns: An array of transactions linked to the account via splits.
    /// - Throws: `TransactionError` if the fetch fails.
    func execute(for accountId: UUID) async throws -> [Transaction] {
        try await repository.fetchAll(for: accountId)
    }
}
