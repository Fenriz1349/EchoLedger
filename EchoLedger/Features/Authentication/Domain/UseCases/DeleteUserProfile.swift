//
//  DeleteUserProfile.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import Foundation

/// Deletes the Firebase Auth account. As a final guard it first sweeps any remaining Storage files
/// for the user — the per-aggregate deletions already removed every referenced file, this catches
/// orphans — then removes the account. Files must go while the session is still valid, so the Auth
/// account deletion is the very last step.
final class DeleteUserProfile {

    private let repository: AuthProviding
    private let deleteDocument: DeleteDocument
    private let userId: UUID

    /// - Parameters:
    ///   - repository: The authentication provider used to delete the account.
    ///   - deleteDocument: UseCase for sweeping any remaining user files from storage.
    ///   - userId: The internal user identifier.
    init(repository: AuthProviding, deleteDocument: DeleteDocument, userId: UUID) {
        self.repository = repository
        self.deleteDocument = deleteDocument
        self.userId = userId
    }

    /// Sweeps any remaining Storage files, then deletes the Auth account and local session.
    func execute() async throws {
        try await deleteDocument.deleteAllUserFiles(userId: userId)
        try await repository.deleteUserProfile()
    }
}
