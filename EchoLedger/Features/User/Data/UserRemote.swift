//
//  UserRemote.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/03/2026.
//

import Foundation

/// Firebase Firestore representation of a User.
/// Lives exclusively in the Data layer — the Domain never sees this struct.
/// Bridges the internal UUID and the Firebase remoteId.
struct UserRemote: Codable {

    // MARK: Properties
    /// Internal UUID used across the app and SwiftData.
    let internalId: String

    /// Firebase Auth uid — used as the Firestore document key.
    let remoteId: String

    let displayName: String
    let email: String
    let photoURL: String?

    // MARK: Mapping
    /// Creates a UserDTO from a Domain User and a Firebase remoteId.
    /// - Parameters:
    ///   - user: The domain user.
    ///   - remoteId: The Firebase Auth uid.
    init(from user: User, remoteId: String) {
        self.internalId = user.id.uuidString
        self.remoteId = remoteId
        self.displayName = user.displayName
        self.email = user.email
        self.photoURL = user.photoURL
    }

    /// Converts the DTO back to a Domain User.
    /// - Returns: A Domain User with the internal UUID restored.
    func toDomain() -> User? {
        guard let uuid = UUID(uuidString: internalId) else { return nil }
        return User(
            id: uuid,
            displayName: displayName,
            email: email,
            photoURL: photoURL
        )
    }
}
