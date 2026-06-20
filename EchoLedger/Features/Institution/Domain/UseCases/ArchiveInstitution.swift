//
//  ArchiveInstitution.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Archives a single institution record. Cascading to its accounts is orchestrated by
/// `ArchiveInstitutionRule`.
final class ArchiveInstitution {

    private let repository: InstitutionProviding

    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionProviding) {
        self.repository = repository
    }

    /// - Parameter id: The unique identifier of the institution to archive.
    /// - Throws: `InstitutionError.notFound` if no institution matches the identifier.
    func execute(id: UUID) async throws {
        try await repository.archive(by: id)
    }
}
