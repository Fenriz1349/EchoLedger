//
//  GetAccounts.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/03/2026.
//

import Foundation

/// Retrieves all accounts belonging to a given institution.
final class GetAccounts {

    private let repository: AccountProviding

    /// - Parameter repository: The data contract for account persistence.
    init(repository: AccountProviding) {
        self.repository = repository
    }

    /// Fetches all accounts for a specific institution, ordered by name.
    /// - Parameter institutionId: The identifier of the institution.
    /// - Returns: An array of accounts belonging to the institution.
    /// - Throws: `AccountError` if the fetch fails.
    func execute(for institutionId: UUID) async throws -> [Account] {
        try await repository.fetchAllActive(for: institutionId)
    }
}
