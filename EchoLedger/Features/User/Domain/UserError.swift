//
//  UserError.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Represents domain-level errors for the User feature.
/// These errors are thrown by UseCases, not by repositories or data sources.
enum UserError: Error, Equatable {

    /// Thrown when no user is found for the given identifier.
    case notFound

    /// Thrown when the user display name is shorter than the minimum allowed length of 2 characters.
    case nameTooShort

    /// Thrown when the user display name exceeds the maximum allowed length of 50 characters.
    case nameTooLong

    /// Thrown when the provided email address format is invalid.
    case invalidEmail

    /// Returns a human-readable description of the error.
    var localizedDescription: String {
        switch self {
        case .notFound:
            return "Utilisateur introuvable."
        case .nameTooShort:
            return "Le nom doit contenir au moins 2 caractères."
        case .nameTooLong:
            return "Le nom ne peut pas dépasser 50 caractères."
        case .invalidEmail:
            return "L'adresse email n'est pas valide."
        }
    }
}
