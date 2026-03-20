//
//  UserModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/03/2026.
//

import Foundation
import SwiftData

/// SwiftData persistent model for User.
/// Maps to and from the Domain User entity via UserLocalDataSource.
@Model
final class UserModel {

    // MARK: Properties
    var id: UUID
    var displayName: String
    var email: String
    var photoURL: String?

    // MARK: Relationships
    @Relationship(deleteRule: .cascade)
    var institutions: [InstitutionModel]

    // MARK: Init
    /// Creates a new UserModel from primitive values.
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
        self.institutions = []
    }

    // MARK: Mapping
    /// Converts this SwiftData model to a Domain User entity.
    func toDomain() -> User {
        User(
            id: id,
            displayName: displayName,
            email: email,
            photoURL: photoURL
        )
    }

    /// Updates this model's properties from a Domain User entity.
    /// - Parameter user: The domain entity with updated values.
    func update(from user: User) {
        self.displayName = user.displayName
        self.email = user.email
        self.photoURL = user.photoURL
    }
}
