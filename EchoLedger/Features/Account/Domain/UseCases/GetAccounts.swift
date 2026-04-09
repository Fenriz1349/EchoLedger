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

    /// Fetches accounts for a specific institution with the given filter.
    /// - Parameters:
    ///   - institutionId: The identifier of the institution.
    ///   - filter: The filter to apply. Defaults to `.active`.
    /// - Returns: An array of accounts ordered by name.
    /// - Throws: `AccountError` if the fetch fails.
    func execute(for institutionId: UUID, filter: AccountFilter = .active) async throws -> [Account] {
        switch filter {
        case .active:   return try await repository.fetchAllActive(for: institutionId)
        case .archived: return try await repository.fetchAllArchived(for: institutionId)
        case .all:      return try await repository.fetchAll(for: institutionId)
        }
    }
}
