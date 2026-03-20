//
//  TransactionType.swift
//  EchoLedger
//
//  Created by Julien Cotte on 11/03/2026.
//

/// Represents the category of a transaction.
/// RawValue is used for Firebase persistence, name is used for display.
enum TransactionType: String, CaseIterable, Codable {
    case initialBalance
    case travel
    case leisure
    case restaurant
    case transport
    case health
    case shopping
    case salary
    case other

    /// Returns the French display name for the transaction type.
    var name: String {
        switch self {
        case .initialBalance: return "Solde initial"
        case .travel:         return "Voyage"
        case .leisure:        return "Loisir"
        case .restaurant:     return "Restaurant"
        case .transport:      return "Transport"
        case .health:         return "Santé"
        case .shopping:       return "Shopping"
        case .salary:         return "Salaire"
        case .other:          return "Autre"
        }
    }

    /// Returns the SF Symbol name associated with the transaction type.
    var icon: String {
        switch self {
        case .initialBalance: return "flag"
        case .travel:         return "airplane"
        case .leisure:        return "gamecontroller"
        case .restaurant:     return "fork.knife"
        case .transport:      return "car"
        case .health:         return "heart.fill"
        case .shopping:       return "cart"
        case .salary:         return "banknote"
        case .other:          return "ellipsis.circle"
        }
    }
}
