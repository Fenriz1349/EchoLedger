//
//  DeleteUser.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/06/2026.
//

import Foundation

/// Permanently deletes a single user record and its avatar file. Cleaning up the user's other data
/// (institutions, accounts, transactions) is orchestrated by `DeleteUserRule`.
final class DeleteUser {

    private let repository: UserProviding
    private let deleteDocument: DeleteDocument

    /// - Parameters:
    ///   - repository: The data contract for user persistence.
    ///   - deleteDocument: UseCase for removing the avatar file from storage.
    init(repository: UserProviding, deleteDocument: DeleteDocument) {
        self.repository = repository
        self.deleteDocument = deleteDocument
    }

    /// Deletes the user's avatar (if any) then the user record. The avatar is deleted first so the
    /// file is never left orphaned.
    /// - Parameter id: The internal identifier of the user to delete.
    func execute(id: UUID) async throws {
        if let user = try? await repository.fetchCurrent(), let photoURL = user.photoURL {
            try await deleteDocument.execute(urlString: photoURL)
        }
        try await repository.delete(by: id)
    }
}
