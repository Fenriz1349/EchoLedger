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
    private let getInstitutions: GetInstitutions
    private let deleteInstitution: DeleteInstitution
    private let userId: UUID

    /// - Parameters:
    ///   - repository: The authentication provider used to delete the account.
    ///   - userStoring: The user data provider for deleting user data.
    ///   - deleteDocument: UseCase for removing the avatar file from storage.
    ///   - getInstitutions: UseCase for listing the user's institutions to cascade their deletion.
    ///   - deleteInstitution: UseCase that cascades deletion to accounts, transactions, and their files.
    ///   - userId: The internal user identifier.
    init(repository: AuthProviding,
         userStoring: UserProviding,
         deleteDocument: DeleteDocument,
         getInstitutions: GetInstitutions,
         deleteInstitution: DeleteInstitution,
         userId: UUID) {
        self.repository = repository
        self.userStoring = userStoring
        self.deleteDocument = deleteDocument
        self.getInstitutions = getInstitutions
        self.deleteInstitution = deleteInstitution
        self.userId = userId
    }

    /// Deletes everything the user owns, in an order that keeps Storage deletes authorized:
    /// every file (transaction attachments, avatar) is removed while the user document still
    /// exists and the session is valid — the document and the Auth account are deleted last.
    /// 1. institutions → accounts → transactions → their attachment files (via the cascade)
    /// 2. avatar file
    /// 3. user document, then the Auth account + local session
    /// Data cleanup is best-effort; only the final account deletion is propagated.
    func execute() async throws {
        if let institutions = try? await getInstitutions.execute(for: userId) {
            for institution in institutions {
                try? await deleteInstitution.execute(id: institution.id)
            }
        }
        if let photoURL = try? await userStoring.fetchCurrent().photoURL {
            try? await deleteDocument.execute(urlString: photoURL)
        }
        try? await userStoring.delete(by: userId)
        try await repository.deleteUserProfile()
    }
}
