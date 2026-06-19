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
    private let deleteDocument: DocumentDeleting
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
         deleteDocument: DocumentDeleting,
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

    /// Deletes everything the user owns, all-or-nothing, in an order that keeps Storage deletes
    /// authorized (files removed while the session is still valid; Auth account deleted last):
    /// 1. every Storage file under the user's folder — nuked directly, not via the cascade, so
    ///    nothing is left behind even if the records are inconsistent.
    /// 2. the Firestore records (institutions → accounts → transactions).
    /// 3. the user document, then the Auth account + local session.
    /// Every step is propagated: a failure aborts and keeps the account, and a retry resumes
    /// safely (re-listing yields only remaining files, and Firestore deletes are idempotent).
    func execute() async throws {
        try await deleteDocument.deleteAllUserFiles(userId: userId)

        let institutions = try await getInstitutions.execute(for: userId)
        for institution in institutions {
            try await deleteInstitution.execute(id: institution.id)
        }
        try await userStoring.delete(by: userId)
        try await repository.deleteUserProfile()
    }
}
