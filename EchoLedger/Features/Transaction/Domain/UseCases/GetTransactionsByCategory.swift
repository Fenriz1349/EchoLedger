//
//  GetTransactionsByCategory.swift
//  EchoLedger
//
//  Created by Julien Cotte on 11/03/2026.
//

import Foundation

/// Retrieves all transactions for a given user filtered by transaction category.
/// Useful for category-based charts and statistics.
final class GetTransactionsByCategory {

    // MARK: Dependencies
    private let repository: TransactionProviding

    // MARK: Init
    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    // MARK: Execute
    /// Fetches transactions for a specific user filtered by category.
    /// - Parameters:
    ///   - userId: The identifier of the user.
    ///   - category: The transaction category to filter by.
    /// - Returns: An array of transactions matching the given category, ordered by date descending.
    /// - Throws: `TransactionError` if the fetch fails.
    func execute(for userId: UUID, category: TransactionCategory) async throws -> [Transaction] {
        let all = try await repository.fetchAll(for: userId)
        return all.filter { $0.category == category }
    }
}
