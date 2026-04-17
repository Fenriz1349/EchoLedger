//
//  AuthLocalSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/04/2026.
//

import Foundation

/// Handles local persistence of the authenticated user's identifier using UserDefaults.
final class AuthLocalSource {

    private let userIdKey = "echoledger.userId"

    /// Returns the stored user ID, or nil if none is found.
    func fetchUserId() -> UUID? {
        guard let stored = UserDefaults.standard.string(forKey: userIdKey) else { return nil }
        return UUID(uuidString: stored)
    }

    /// Persists the given user ID locally.
    func saveUserId(_ userId: UUID) {
        UserDefaults.standard.set(userId.uuidString, forKey: userIdKey)
    }

    /// Removes the stored user ID from local storage.
    func clearUserId() {
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }
}
