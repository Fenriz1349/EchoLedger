//
//  DeleteUserProfile.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import Foundation

/// Permanently deletes the current user account and all associated remote data.
final class DeleteUserProfile {

    private let repository: AuthProviding
    private let userStoring: UserProviding
    private let deleteDocument: DeleteDocument
    private let userId: UUID

    /// - Parameters:
    ///   - repository: The authentication provider used to delete the account.
    ///   - userStoring: The user data provider for deleting user data.
    ///   - deleteDocument: UseCase for removing the avatar file from storage.
    ///   - userId: The internal user identifier.
    init(repository: AuthProviding, userStoring: UserProviding, deleteDocument: DeleteDocument, userId: UUID) {
        self.repository = repository
        self.userStoring = userStoring
        self.deleteDocument = deleteDocument
        self.userId = userId
    }

    /// Deletes the avatar file, the user data, the Firebase Auth account, and clears the local session.
    /// The avatar is removed first, while the user document still exists and the session is valid
    /// (Storage rules resolve ownership via that document). Avatar removal is best-effort.
    func execute() async throws {
        if let photoURL = try? await userStoring.fetchCurrent().photoURL {
            try? await deleteDocument.execute(urlString: photoURL)
        }
        try? await userStoring.delete(by: userId)
        try await repository.deleteUserProfile()
    }
}
