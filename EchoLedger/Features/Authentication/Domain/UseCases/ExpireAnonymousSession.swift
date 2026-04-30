//
//  ExpireAnonymousSession.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/04/2026.
//

import Foundation

/// Checks whether the current anonymous session has exceeded its 7-day validity period.
/// If so, deletes the Firebase account, Firestore data, and clears local session state.
final class ExpireAnonymousSession {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to check and expire the session.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// Expires the anonymous session if it has exceeded 7 days.
    /// - Returns: `true` if the session was expired and deleted, `false` if still valid.
    func execute() async -> Bool {
        guard repository.isAnonymousSessionExpired() else { return false }
        await repository.expireAnonymousSession()
        return true
    }
}
