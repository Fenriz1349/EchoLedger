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
///
/// `displayName` uses `|` as a separator between first and last name (e.g. `"Jean-Pierre|Du Saint"`),
/// allowing compound names on both sides without ambiguity.
struct User: Identifiable, Equatable, Codable, Sendable {

    let id: UUID
    let displayName: String
    let email: String
    let photoURL: String?

    /// The first name extracted from `displayName` using the `|` separator.
    var firstName: String { displayName.components(separatedBy: "|").first ?? displayName }

    /// The last name extracted from `displayName` using the `|` separator.
    var lastName: String { displayName.components(separatedBy: "|").last ?? "" }

    /// Creates a new User.
    /// - Parameters:
    ///   - id: Internal unique identifier. Defaults to a new UUID.
    ///   - displayName: Pipe-separated full name in the form `"firstName|lastName"`.
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
