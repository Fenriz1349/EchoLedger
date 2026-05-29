//
//  DeleteUserAccount.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import Foundation

/// Permanently deletes the current user account and all associated remote data.
final class DeleteUserAccount {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to delete the account.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// Executes the account deletion.
    func execute() async throws {
        try await repository.deleteUserAccount()
    }
}
