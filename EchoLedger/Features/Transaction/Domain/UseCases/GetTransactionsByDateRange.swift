//
//  GetTransactionsByDateRange.swift
//  EchoLedger
//
//  Created by Julien Cotte on 11/03/2026.
//

import Foundation

// MARK: - GetTransactionsByDateRange
/// Retrieves all transactions for a given account within a specific date range.
/// Useful for monthly or custom period statistics and charts.
final class GetTransactionsByDateRange {

    // MARK: Dependencies
    private let repository: TransactionRepositoryProtocol

    // MARK: Init
    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: Execute
    /// Fetches transactions for a specific account within a date range (inclusive).
    /// - Parameters:
    ///   - accountId: The identifier of the account.
    ///   - from: The start date of the range (inclusive).
    ///   - to: The end date of the range (inclusive).
    /// - Returns: An array of transactions within the date range, ordered by date descending.
    /// - Throws: `TransactionError` if the fetch fails.
    func execute(for accountId: UUID, from: Date, to: Date = Date()) async throws -> [Transaction] {
        guard from <= to else {
            throw TransactionError.invalidDateRange
        }
        let all = try await repository.fetchAll(for: accountId)
        return all.filter { $0.date >= from && $0.date <= to }
    }
}
