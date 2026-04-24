//
//  SyncStatus.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Represents the current state of a sync operation.
enum SyncStatus: Equatable {
    /// No sync is in progress and none has completed yet.
    case waiting
    /// A sync is currently running.
    case syncing
    /// The last sync completed successfully at the associated date.
    case success(Date)
    /// The last sync failed with the associated error message.
    case failure(String)
}
