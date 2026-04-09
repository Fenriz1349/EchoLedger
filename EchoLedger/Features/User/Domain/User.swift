//
//  User.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Represents an authenticated user of the application.
/// Only knows its internal UUID — remote identifiers are handled exclusively in the Data layer.
/// Owns institutions which in turn own accounts.
struct User: Identifiable, Equatable, Codable, Sendable {

    let id: UUID
    let displayName: String
    let email: String
    let photoURL: String?

    /// Creates a new User.
    /// - Parameters:
    ///   - id: Internal unique identifier. Defaults to a new UUID.
    ///   - displayName: Display name of the user.
    ///   - email: Email address of the user.
    ///   - photoURL: Optional URL string pointing to the user's profile photo.
    init(
        id: UUID = UUID(),
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
