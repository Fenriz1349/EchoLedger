//
//  AddInstitution.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

/// Handles the creation of a new institution for a given user.
/// Enforces all business rules before persisting.
final class AddInstitution {

    // MARK: Dependencies
    private let repository: InstitutionProviding

    // MARK: Init
    /// - Parameter repository: The data contract for institution persistence.
    init(repository: InstitutionProviding) {
        self.repository = repository
    }

    // MARK: Execute
    /// Creates and persists a new institution.
    /// - Parameter input: The data required to create the institution.
    /// - Throws: `InstitutionError` if any business rule is violated.
    func execute(_ input: AddInstitutionInput) async throws {
        let trimmed = input.name.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            throw InstitutionError.nameTooShort
        }
        guard trimmed.count <= 50 else {
            throw InstitutionError.nameTooLong
        }
        let existing = try await repository.fetchAll(for: input.userId)
        guard !existing.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) else {
            throw InstitutionError.duplicateName
        }

        let institution = Institution(
            userId: input.userId,
            name: trimmed,
            category: input.category,
            logoURL: input.logoURL,
            updatedAt: Date()
        )
        try await repository.save(institution)
    }
}
