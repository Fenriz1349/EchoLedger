//
//  AuthError.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/04/2026.
//

import Foundation

/// Errors that can occur during authentication operations.
enum AuthError: Error, Equatable, LocalizedError {
    /// Thrown when the sign-in process fails.
    case signInFailed
    /// Thrown when the sign-out process fails.
    case signOutFailed
    /// Thrown when no active session is found.
    case noSessionFound

    var localizedDescription: String {
        switch self {
        case .signInFailed: return "La connexion a échoué. Veuillez réessayer."
        case .signOutFailed: return "La déconnexion a échoué."
        case .noSessionFound: return "Aucune session active."
        }
    }
}
