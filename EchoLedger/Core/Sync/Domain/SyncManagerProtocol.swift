//
//  SyncManagerProtocol.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Defines the contract for synchronising remote Firestore data into local SwiftData storage.
protocol SyncManagerProtocol {
    /// The current synchronisation state.
    var status: SyncStatus { get }
    /// The date of the last successful synchronisation, or `nil` if none has occurred.
    var lastSyncDate: Date? { get }
    /// Pulls all remote data and upserts it into local storage.
    func sync() async
}
