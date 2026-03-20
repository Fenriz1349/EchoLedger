//
//  UpdateUser.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Handles updating the current user's profile.
/// Enforces all business rules before persisting.
final class UpdateUser {

    // MARK: Dependencies
    private let repository: UserProviding

    // MARK: Init
    /// - Parameter repository: The data contract for user persistence.
    init(repository: UserProviding) {
        self.repository = repository
    }

    // MARK: Execute
    /// Updates the current user's profile with new values.
    /// - Parameters:
    ///   - id: The internal unique identifier of the user to update.
    ///   - displayName: Updated display name. Must be between 2 and 50 characters.
    ///   - email: Updated email address.
    ///   - photoURL: Updated optional profile photo URL.
    /// - Throws: `UserError` if any business rule is violated.
    func execute(
        id: UUID,
        displayName: String,
        email: String,
        photoURL: String? = nil
    ) async throws {
        let trimmed = displayName.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            throw UserError.nameTooShort
        }
        guard trimmed.count <= 50 else {
            throw UserError.nameTooLong
        }
        guard email.contains("@") else {
            throw UserError.invalidEmail
        }

        let updated = User(
            id: id,
            displayName: trimmed,
            email: email,
            photoURL: photoURL
        )
        try await repository.update(updated)
    }
}
