//
//  DeleteUserRule.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/06/2026.
//

import Foundation

/// Orchestrates full account deletion: cascades every institution (→ accounts → transactions andt heir files),
/// Deletes the user record and avatar, then deletes the Firebase Auth account.
/// The Auth account goes last so Storage deletes stay authorized while the session is valid.
final class DeleteUserRule {

    private let getInstitutions: GetInstitutions
    private let deleteInstitutionRule: DeleteInstitutionRule
    private let deleteUser: DeleteUser
    private let deleteUserProfile: DeleteUserProfile
    private let userId: UUID

    init(getInstitutions: GetInstitutions,
         deleteInstitutionRule: DeleteInstitutionRule,
         deleteUser: DeleteUser,
         deleteUserProfile: DeleteUserProfile,
         userId: UUID) {
        self.getInstitutions = getInstitutions
        self.deleteInstitutionRule = deleteInstitutionRule
        self.deleteUser = deleteUser
        self.deleteUserProfile = deleteUserProfile
        self.userId = userId
    }

    /// Deletes everything the user owns, then the user record, then the Auth account.
    func execute() async throws {
        let institutions = try await getInstitutions.execute(for: userId)
        for institution in institutions {
            try await deleteInstitutionRule.execute(id: institution.id)
        }
        try await deleteUser.execute(id: userId)
        try await deleteUserProfile.execute()
    }
}
