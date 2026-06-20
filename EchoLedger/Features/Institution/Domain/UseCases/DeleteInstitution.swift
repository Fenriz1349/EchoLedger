//
//  DeleteInstitution.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Permanently deletes a single institution record. Cleaning up its accounts (and their
/// transactions) is orchestrated by `DeleteInstitutionRule`.
final class DeleteInstitution {

    // MARK: Dependencies
    private let repository: InstitutionProviding

    // MARK: Init
    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionProviding) {
        self.repository = repository
    }

    // MARK: Execute
    /// - Parameter id: The unique identifier of the institution to delete.
    /// - Throws: `InstitutionError.notFound` if no institution matches the identifier.
    func execute(id: UUID) async throws {
        try await repository.delete(by: id)
    }
}
