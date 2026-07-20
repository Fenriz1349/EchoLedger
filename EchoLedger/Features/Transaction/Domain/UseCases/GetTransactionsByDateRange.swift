//
//  GetTransactionsByDateRange.swift
//  EchoLedger
//
//  Created by Julien Cotte on 11/03/2026.
//

import Foundation

/// Retrieves all transactions for a given user within a specific date range.
/// Useful for monthly or custom period statistics and charts.
final class GetTransactionsByDateRange {

    private let repository: TransactionProviding

    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    /// Fetches transactions for a specific user within a date range (inclusive).
    /// - Parameters:
    ///   - userId: The identifier of the user.
    ///   - from: The start date of the range (inclusive).
    ///   - to: The end date of the range (inclusive). Defaults to the current date.
    /// - Returns: An array of transactions within the date range, ordered by date descending.
    /// - Throws: `TransactionError.invalidDateRange` if from is after to.
    func execute(for userId: UUID, from fromDate: Date, to toDate: Date = Date()) async throws -> [Transaction] {
        guard fromDate <= toDate else {
            throw TransactionError.invalidDateRange
        }
        let all = try await repository.fetchAll(for: userId)
        return all.filter { $0.date >= fromDate && $0.date <= toDate }
    }
}
