//
//  GetTransactionsByType.swift
//  EchoLedger
//
//  Created by Julien Cotte on 11/03/2026.
//

import Foundation

// MARK: - GetTransactionsByType
/// Retrieves all transactions for a given account filtered by transaction type.
/// Useful for category-based charts and statistics.
final class GetTransactionsByType {

    // MARK: Dependencies
    private let repository: TransactionRepositoryProtocol

    // MARK: Init
    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: Execute
    /// Fetches transactions for a specific account filtered by type.
    /// - Parameters:
    ///   - accountId: The identifier of the account.
    ///   - type: The transaction category to filter by.
    /// - Returns: An array of transactions matching the given type, ordered by date descending.
    /// - Throws: `TransactionError` if the fetch fails.
    func execute(for accountId: UUID, type: TransactionType) async throws -> [Transaction] {
        let all = try await repository.fetchAll(for: accountId)
        return all.filter { $0.type == type }
    }
}
