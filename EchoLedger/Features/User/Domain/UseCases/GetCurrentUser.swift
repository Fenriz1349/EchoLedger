//
//  GetCurrentUser.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Retrieves the current authenticated user.
final class GetCurrentUser {

    // MARK: Dependencies
    private let repository: UserProviding

    // MARK: Init
    /// - Parameter repository: The data contract for user persistence.
    init(repository: UserProviding) {
        self.repository = repository
    }

    // MARK: Execute
    /// Fetches the current authenticated user.
    /// - Returns: The current user.
    /// - Throws: `UserError.notFound` if no user is currently authenticated.
    func execute() async throws -> User {
        try await repository.fetchCurrent()
    }
}
