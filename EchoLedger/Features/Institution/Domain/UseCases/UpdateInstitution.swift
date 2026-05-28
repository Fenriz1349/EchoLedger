//
//  UpdateInstitution.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Handles updating an existing institution.
/// Re-enforces all business rules before persisting.
final class UpdateInstitution {

    // MARK: Dependencies
    private let repository: InstitutionProviding

    // MARK: Init
    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionProviding) {
        self.repository = repository
    }

    // MARK: Execute
    /// Updates an existing institution with new values.
    /// - Parameter input: The data required to update the institution.
    /// - Throws: `InstitutionError` if any business rule is violated.
    func execute(_ input: UpdateInstitutionInput) async throws {
        let trimmed = input.name.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            throw InstitutionError.nameTooShort
        }
        guard trimmed.count <= 50 else {
            throw InstitutionError.nameTooLong
        }
        let allInstitutions = try await repository.fetchAll(for: input.userId)
        guard !allInstitutions.contains(where: { $0.name.lowercased() == trimmed.lowercased() && $0.id != input.id }) else {
            throw InstitutionError.duplicateName
        }

        let current = try await repository.fetch(by: input.id)
        let updated = Institution(
            id: input.id,
            userId: input.userId,
            name: trimmed,
            category: input.category,
            logoURL: input.logoURL,
            isArchived: current.isArchived,
            updatedAt: Date()
        )
        try await repository.update(updated)
    }
}
