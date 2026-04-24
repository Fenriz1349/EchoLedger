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
    /// Thrown when the email address is already linked to an existing account.
    case emailAlreadyInUse
    /// Thrown when the provided password does not meet strength requirements.
    case weakPassword
    /// Thrown when the email or password is incorrect.
    case invalidCredentials
    /// Thrown when the two password entries do not match.
    case passwordsDoNotMatch
    /// Thrown when linking an anonymous account to a permanent account fails.
    case accountLinkingFailed
    /// Thrown when the account deletion process fails.
    case deletionFailed

    var errorDescription: String? {
        switch self {
        case .signInFailed:         return "La connexion a échoué. Veuillez réessayer."
        case .signOutFailed:        return "La déconnexion a échoué."
        case .noSessionFound:       return "Aucune session active."
        case .emailAlreadyInUse:    return "Cette adresse email est déjà utilisée."
        case .weakPassword:         return "Le mot de passe doit contenir au moins 8 caractères, une majuscule, un chiffre et un caractère spécial."
        case .invalidCredentials:   return "Email ou mot de passe incorrect."
        case .passwordsDoNotMatch:  return "Les mots de passe ne correspondent pas."
        case .accountLinkingFailed: return "La migration du compte démo a échoué."
        case .deletionFailed:       return "La suppression du compte a échoué."
        }
    }
}
