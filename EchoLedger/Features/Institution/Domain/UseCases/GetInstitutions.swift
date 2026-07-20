//
//  GetInstitutions.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

/// Retrieves all institutions belonging to a given user.
final class GetInstitutions {

    // MARK: Dependencies
    private let repository: InstitutionProviding

    // MARK: Init
    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionProviding) {
        self.repository = repository
    }

    // MARK: Execute
    /// Fetches all institutions for a specific user, ordered by name.
    /// - Parameter userId: The identifier of the user.
    /// - Returns: An array of institutions belonging to the user.
    /// - Throws: `InstitutionError` if the fetch fails.
    func execute(for userId: UUID) async throws -> [Institution] {
        try await repository.fetchAll(for: userId)
    }
}
