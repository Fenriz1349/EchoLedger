//
//  InstitutionError.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

/// Represents domain-level errors for the Institution feature.
/// These errors are thrown by UseCases, not by repositories or data sources.
enum InstitutionError: Error, Equatable, LocalizedError {

    /// Thrown when the institution name is shorter than the minimum allowed length.
    case nameTooShort

    /// Thrown when the institution name exceeds the maximum allowed length.
    case nameTooLong

    /// Thrown when an institution with the same name already exists for this user.
    case duplicateName

    /// Thrown when no institution is found for the given identifier.
    case notFound

    /// Returns a human-readable description of the error.
    var localizedDescription: String {
        switch self {
        case .nameTooShort:
            return "Le nom de l'établissement doit contenir au moins 2 caractères."
        case .nameTooLong:
            return "Le nom de l'établissement ne peut pas dépasser 50 caractères."
        case .duplicateName:
            return "Un établissement avec ce nom existe déjà."
        case .notFound:
            return "Établissement introuvable."
        }
    }
}
