//
//  UnarchiveInstitution.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Restores a single institution record to active status. Cascading to its accounts is orchestrated
/// by `UnarchiveInstitutionRule`.
final class UnarchiveInstitution {

    private let repository: InstitutionProviding

    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionProviding) {
        self.repository = repository
    }

    /// - Parameter id: The unique identifier of the institution to unarchive.
    /// - Throws: `InstitutionError.notFound` if no institution matches the identifier.
    func execute(id: UUID) async throws {
        try await repository.unarchive(by: id)
    }
}
