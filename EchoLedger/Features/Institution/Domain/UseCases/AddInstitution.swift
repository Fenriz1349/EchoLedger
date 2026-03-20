//
//  AddInstitution.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

// MARK: - AddInstitution
/// Handles the creation of a new institution for a given user.
/// Enforces all business rules before persisting.
final class AddInstitution {

    // MARK: Dependencies
    private let repository: InstitutionRepositoryProtocol

    // MARK: Init
    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: Execute
    /// Creates and persists a new institution.
    /// - Parameters:
    ///   - userId: The identifier of the user this institution belongs to.
    ///   - name: Name of the institution. Must be between 2 and 50 characters.
    ///   - type: Category of the institution.
    ///   - logoURL: Optional URL string pointing to the institution's logo.
    /// - Throws: `InstitutionError` if any business rule is violated.
    func execute(
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
        guard !existing.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) else {
            throw InstitutionError.duplicateName
        }

        let institution = Institution(
            userId: userId,
            name: trimmed,
            type: type,
            logoURL: logoURL
        )
        try await repository.save(institution)
    }
}
