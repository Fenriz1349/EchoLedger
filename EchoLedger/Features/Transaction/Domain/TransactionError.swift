//
//  TransactionError.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

// MARK: - TransactionError
/// Represents domain-level errors for the Transaction feature.
/// These errors are thrown by UseCases, not by repositories or data sources.
enum TransactionError: Error, Equatable {

    /// Thrown when a transaction is created or updated with no splits.
    case missingSplits

    /// Thrown when the sum of split amounts does not equal the transaction's totalAmount.
    case splitAmountMismatch

    /// Thrown when a split amount is zero or negative.
    case invalidSplitAmount

    /// Thrown when the totalAmount is zero or negative.
    case invalidTotalAmount

    /// Thrown when the transaction label is empty.
    case emptyLabel

    /// Thrown when no transaction is found for the given identifier.
    case notFound
    
    /// Thrown when the start date is after the end date in a date range query.
    case invalidDateRange

    /// Returns a human-readable description of the error.
    var localizedDescription: String {
        switch self {
        case .missingSplits:
            return "Une transaction doit avoir au moins une ventilation."
        case .splitAmountMismatch:
            return "La somme des ventilations ne correspond pas au montant total."
        case .invalidSplitAmount:
            return "Le montant d'une ventilation doit être positif."
        case .invalidTotalAmount:
            return "Le montant total doit être positif."
        case .emptyLabel:
            return "Le libellé de la transaction ne peut pas être vide."
        case .notFound:
            return "Transaction introuvable."
        case .invalidDateRange:
            return "La date de début doit être antérieure à la date de fin."
        }
    }
}
