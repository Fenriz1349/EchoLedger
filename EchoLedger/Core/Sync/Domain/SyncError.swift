//
//  SyncError.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/04/2026.
//

import Foundation

/// Represents errors that can occur during local-remote synchronisation.
enum SyncError: Error, LocalizedError, Equatable {

    /// Thrown when the remote Firebase save fails after a successful local save.
    case remoteSaveFailed

    /// Thrown when the full sync pull from Firebase fails.
    case syncFailed

    var errorDescription: String? {
        switch self {
        case .remoteSaveFailed:
            return "Sauvegarde Firebase échouée — données conservées localement. Synchronisez pour réessayer."
        case .syncFailed:
            return "La synchronisation a échoué. Vérifiez votre connexion et réessayez."
        }
    }
}
