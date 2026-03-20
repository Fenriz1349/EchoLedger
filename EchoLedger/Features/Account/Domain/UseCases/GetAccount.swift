//
//  GetAccount.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

/// Retrieves a single account by its unique identifier.
final class GetAccount {

    // MARK: Dependencies
    private let repository: AccountProviding

    // MARK: Init
    /// - Parameter repository: The data contract for account persistence.
    init(repository: AccountProviding) {
        self.repository = repository
    }

    // MARK: Execute
    /// Fetches a single account by its identifier.
    /// - Parameter id: The unique identifier of the account.
    /// - Returns: The matching account.
    /// - Throws: `AccountError.notFound` if no account matches the identifier.
    func execute(id: UUID) async throws -> Account {
        try await repository.fetch(by: id)
    }
}

