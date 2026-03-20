//
//  UpdateInstitution.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

// MARK: - UpdateInstitution
/// Handles updating an existing institution.
/// Re-enforces all business rules before persisting.
final class UpdateInstitution {

    // MARK: Dependencies
    private let repository: InstitutionRepositoryProtocol

    // MARK: Init
    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: Execute
    /// Updates an existing institution with new values.
    /// - Parameters:
    ///   - id: The unique identifier of the institution to update.
    ///   - userId: The identifier of the user this institution belongs to.
    ///   - name: Updated name. Must be between 2 and 50 characters.
    ///   - type: Updated category.
    ///   - logoURL: Updated optional logo URL.
    /// - Throws: `InstitutionError` if any business rule is violated.
    func execute(
        id: UUID,
        userId: UUID,
        name: String,
        type: InstitutionType,
        logoURL: String? = nil
    ) async throws {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            throw InstitutionError.nameTooShort
        }
        guard trimmed.count <= 50 else {
            throw InstitutionError.nameTooLong
        }
        let existing = try await repository.fetchAll(for: userId)
        guard !existing.contains(where: { $0.name.lowercased() == trimmed.lowercased() && $0.id != id }) else {
            throw InstitutionError.duplicateName
        }

        let updated = Institution(
            id: id,
            userId: userId,
            name: trimmed,
            type: type,
            logoURL: logoURL
        )
        try await repository.update(updated)
    }
}
