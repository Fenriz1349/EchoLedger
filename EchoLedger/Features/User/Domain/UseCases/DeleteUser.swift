//
//  DeleteUser.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/06/2026.
//

import Foundation

/// Permanently deletes a single user record. Cleaning up the user's Storage files (avatar
/// included) and other data (institutions, accounts, transactions) is orchestrated by
/// `DeleteUserRule`, which sweeps Storage first — storage.rules authorizes access to a user's
/// files by checking that this very record still exists.
final class DeleteUser {

    private let repository: UserProviding

    /// - Parameter repository: The data contract for user persistence.
    init(repository: UserProviding) {
        self.repository = repository
    }

    /// - Parameter id: The internal identifier of the user to delete.
    func execute(id: UUID) async throws {
        try await repository.delete(by: id)
    }
}
