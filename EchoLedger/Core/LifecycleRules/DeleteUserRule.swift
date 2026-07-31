//
//  DeleteUserRule.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/06/2026.
//

import Foundation

/// Orchestrates full account deletion. Order matters: storage.rules authorizes access to a user's
/// Storage files by checking that the Firestore `users/{userId}` document still exists, so the
/// Storage sweep must run before that document is deleted — and the Auth account goes last so
/// every Firestore/Storage step above still runs with a valid, authorized session.
final class DeleteUserRule {

    private let deleteDocument: DocumentDeleting
    private let purgeDeletedEntities: PurgeDeletedEntities
    private let getInstitutions: GetInstitutions
    private let deleteInstitutionRule: DeleteInstitutionRule
    private let deleteUser: DeleteUser
    private let deleteUserProfile: DeleteUserProfile
    private let userId: UUID

    init(deleteDocument: DocumentDeleting,
         purgeDeletedEntities: PurgeDeletedEntities,
         getInstitutions: GetInstitutions,
         deleteInstitutionRule: DeleteInstitutionRule,
         deleteUser: DeleteUser,
         deleteUserProfile: DeleteUserProfile,
         userId: UUID) {
        self.deleteDocument = deleteDocument
        self.purgeDeletedEntities = purgeDeletedEntities
        self.getInstitutions = getInstitutions
        self.deleteInstitutionRule = deleteInstitutionRule
        self.deleteUser = deleteUser
        self.deleteUserProfile = deleteUserProfile
        self.userId = userId
    }

    /// Deletes, in order: every Storage file (avatar included), the deletedEntities history trace,
    /// every institution/account/transaction, the user record, then the Auth account.
    func execute() async throws {
        do {
            try await deleteDocument.deleteAllUserFiles(userId: userId)
        } catch {
            throw LifecycleError.filesCleanupFailed
        }

        do {
            try await purgeDeletedEntities.execute()
        } catch {
            throw LifecycleError.historyPurgeFailed
        }

        do {
            let institutions = try await getInstitutions.execute(for: userId)
            for institution in institutions {
                try await deleteInstitutionRule.execute(id: institution.id)
            }
        } catch {
            throw LifecycleError.dataCascadeFailed
        }

        do {
            try await deleteUser.execute(id: userId)
        } catch {
            throw LifecycleError.userRecordDeletionFailed
        }

        do {
            try await deleteUserProfile.execute()
        } catch {
            throw LifecycleError.authAccountDeletionFailed
        }
    }
}
