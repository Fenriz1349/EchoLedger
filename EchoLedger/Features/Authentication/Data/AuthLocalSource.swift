//
//  AuthLocalSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/04/2026.
//

import Foundation

/// Handles local persistence of the authenticated user's identifier using UserDefaults.
final class AuthLocalSource {

    private let defaults: UserDefaults
    private let userIdKey = "echoledger.userId"
    private let anonymousCreationDateKey = "echoledger.anonymousCreationDate"

    /// - Parameter defaults: The UserDefaults instance to use. Defaults to `.standard`.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Returns the stored user ID, or nil if none is found.
    func fetchUserId() -> UUID? {
        guard let stored = defaults.string(forKey: userIdKey) else { return nil }
        return UUID(uuidString: stored)
    }

    /// Persists the given user ID locally.
    func saveUserId(_ userId: UUID) {
        defaults.set(userId.uuidString, forKey: userIdKey)
    }

    /// Removes the stored user ID from local storage.
    func clearUserId() {
        defaults.removeObject(forKey: userIdKey)
    }

    /// Persists the creation date of the current anonymous session.
    func saveAnonymousCreationDate(_ date: Date = Date()) {
        defaults.set(date.timeIntervalSince1970, forKey: anonymousCreationDateKey)
    }

    /// Returns the stored anonymous session creation date, or nil if none exists.
    func fetchAnonymousCreationDate() -> Date? {
        let interval = defaults.double(forKey: anonymousCreationDateKey)
        guard interval > 0 else { return nil }
        return Date(timeIntervalSince1970: interval)
    }

    /// Removes the stored anonymous session creation date.
    func clearAnonymousCreationDate() {
        defaults.removeObject(forKey: anonymousCreationDateKey)
    }

    /// Returns true if the stored creation date exceeds 7 days ago.
    func isAnonymousSessionExpired() -> Bool {
        guard let creationDate = fetchAnonymousCreationDate() else { return false }
        return Date().timeIntervalSince(creationDate) > 7 * 24 * 3600
    }

    /// Returns the number of days remaining in the anonymous demo session, or nil if no date is stored.
    func anonymousDaysRemaining() -> Int? {
        guard let creationDate = fetchAnonymousCreationDate() else { return nil }
        let elapsed = Int(Date().timeIntervalSince(creationDate) / (24 * 3600))
        return max(0, 7 - elapsed)
    }
}
