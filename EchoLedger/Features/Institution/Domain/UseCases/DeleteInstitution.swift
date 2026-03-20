//
//  DeleteInstitution.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Handles the deletion of an institution and all its associated accounts.
final class DeleteInstitution {

    // MARK: Dependencies
    private let repository: InstitutionProviding

    // MARK: Init
    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionProviding) {
        self.repository = repository
    }

    // MARK: Execute
    /// Deletes an institution and all its associated accounts permanently.
    /// - Parameter id: The unique identifier of the institution to delete.
    /// - Throws: `InstitutionError.notFound` if no institution matches the identifier.
    func execute(id: UUID) async throws {
        try await repository.delete(by: id)
    }
}
