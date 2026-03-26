//
//  UpdateUserInput.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation

/// Encapsulates all parameters required to update a user's profile.
struct UpdateUserInput {
    let id: UUID
    let displayName: String
    let email: String
    let photoURL: String?

    /// Creates a new UpdateUserInput.
    /// - Parameters:
    ///   - id: The internal unique identifier of the user to update.
    ///   - displayName: Updated display name. Must be between 2 and 50 characters.
    ///   - email: Updated email address.
    ///   - photoURL: Updated optional profile photo URL.
    init(
        id: UUID,
        displayName: String,
        email: String,
        photoURL: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.photoURL = photoURL
    }
}
