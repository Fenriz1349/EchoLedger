//
//  GetInstitution.swift
//  EchoLedger
//
//  Created by Julien Cotte on 13/03/2026.
//

import Foundation

// MARK: - GetInstitution
/// Retrieves a single institution by its unique identifier.
final class GetInstitution {

    // MARK: Dependencies
    private let repository: InstitutionRepositoryProtocol

    // MARK: Init
    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: Execute
    /// Fetches a single institution by its identifier.
    /// - Parameter id: The unique identifier of the institution.
    /// - Returns: The matching institution.
    /// - Throws: `InstitutionError.notFound` if no institution matches the identifier.
    func execute(id: UUID) async throws -> Institution {
        try await repository.fetch(by: id)
    }
}
