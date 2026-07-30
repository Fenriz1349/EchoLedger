//
//  LifecycleError.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/07/2026.
//

import Foundation

/// Identifies which step of a multi-step LifecycleRule failed, so a toast can say more than
/// "une erreur est survenue" — e.g. which stage of full account deletion broke.
enum LifecycleError: Error, Equatable, LocalizedError {

    /// Thrown when the Storage files sweep fails.
    case filesCleanupFailed
    /// Thrown when purging the deletedEntities history trace fails.
    case historyPurgeFailed
    /// Thrown when cascading institutions/accounts/transactions fails.
    case dataCascadeFailed
    /// Thrown when deleting the user record fails.
    case userRecordDeletionFailed
    /// Thrown when deleting the Firebase Auth account fails.
    case authAccountDeletionFailed

    var errorDescription: String? {
        switch self {
        case .filesCleanupFailed:
            return "La suppression des fichiers a échoué."
        case .historyPurgeFailed:
            return "La purge de l'historique a échoué."
        case .dataCascadeFailed:
            return "La suppression des comptes et transactions a échoué."
        case .userRecordDeletionFailed:
            return "La suppression du profil utilisateur a échoué."
        case .authAccountDeletionFailed:
            return "La suppression du compte d'authentification a échoué."
        }
    }
}
