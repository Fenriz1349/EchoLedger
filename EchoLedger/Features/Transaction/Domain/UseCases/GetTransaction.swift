//
//  GetTransaction.swift
//  EchoLedger
//
//  Created by Julien Cotte on 11/03/2026.
//

import Foundation

/// Retrieves a single transaction by its unique identifier.
final class GetTransaction {

    private let repository: TransactionProviding

    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    /// Fetches a single transaction by its identifier.
    /// - Parameter id: The unique identifier of the transaction.
    /// - Returns: The matching transaction.
    /// - Throws: `TransactionError.notFound` if no transaction matches the identifier.
    func execute(id: UUID) async throws -> Transaction {
        try await repository.fetch(by: id)
    }
}
