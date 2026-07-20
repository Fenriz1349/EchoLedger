//
//  SyncMetadata.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Persists the timestamp of the last successful sync in UserDefaults.
struct SyncMetadata {
    private static let key = "echoledger.lastSync"

    /// The date of the last successful sync, or `nil` if no sync has been recorded.
    static var lastSyncDate: Date? {
        UserDefaults.standard.object(forKey: key) as? Date
    }

    /// Records the current date as the last successful sync timestamp.
    static func save() {
        UserDefaults.standard.set(Date(), forKey: key)
    }
}
