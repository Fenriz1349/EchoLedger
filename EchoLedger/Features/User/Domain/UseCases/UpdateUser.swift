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

    private let repository: UserProviding

    /// - Parameter repository: The data contract for user persistence.
    init(repository: UserProviding) {
        self.repository = repository
    }

    /// Updates the current user's profile with new values.
    /// - Parameter input: The data required to update the user.
    /// - Throws: `UserError` if any business rule is violated.
    func execute(_ input: UpdateUserInput) async throws {
        let firstName = input.firstName.trimmingCharacters(in: .whitespaces)
        let lastName = input.lastName.trimmingCharacters(in: .whitespaces)
        guard firstName.count <= 50 else { throw UserError.nameTooLong }
        guard lastName.count <= 50 else { throw UserError.nameTooLong }
        guard input.email.contains("@") else { throw UserError.invalidEmail }

        let updated = User(
            id: input.id,
            displayName: "\(firstName)|\(lastName)",
            email: input.email,
            photoURL: input.photoURL
        )
        try await repository.update(updated)
    }
}
