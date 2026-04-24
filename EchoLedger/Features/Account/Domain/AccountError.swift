//
//  AccountError.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

/// Represents domain-level errors for the Account feature.
/// These errors are thrown by UseCases, not by repositories or data sources.
enum AccountError: Error, Equatable, LocalizedError {

    /// Thrown when the account name is shorter than the minimum allowed length of 2 characters.
    case nameTooShort

    /// Thrown when the account name exceeds the maximum allowed length of 50 characters.
    case nameTooLong

    /// Thrown when an account with the same name already exists for this institution.
    case duplicateName

    /// Thrown when no account is found for the given identifier.
    case notFound

    /// Thrown when loading accounts fails.
    case loadFailed

    /// Thrown when archiving an account fails.
    case archiveFailed

    /// Returns a human-readable description of the error.
    var errorDescription: String? {
        switch self {
        case .nameTooShort:
            return "Le nom du compte doit contenir au moins 2 caractères."
        case .nameTooLong:
            return "Le nom du compte ne peut pas dépasser 50 caractères."
        case .duplicateName:
            return "Un compte avec ce nom existe déjà dans cet établissement."
        case .notFound:
            return "Compte introuvable."
        case .loadFailed:
            return "Impossible de charger les comptes."
        case .archiveFailed:
            return "Impossible d'archiver le compte."
        }
    }
}
