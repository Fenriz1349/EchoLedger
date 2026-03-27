//
//  AccountCategory.swift
//  EchoLedger
//
//  Created by Julien Cotte on 18/11/2025.
//

import Foundation

/// Represents the category of a financial account.
/// RawValue is used for Firebase persistence, name is used for display.
enum AccountCategory: String, CaseIterable, Codable, Sendable {
    case checking
    case savings
    case creditCard
    case crypto
    case giftCard
    case mealVoucher
    case investment
    case cash
    case other

    /// Returns the French display name for the account category.
    var name: String {
        switch self {
        case .checking:     return "Compte courant"
        case .savings:      return "Épargne"
        case .creditCard:   return "Carte de crédit"
        case .crypto:       return "Crypto"
        case .giftCard:     return "Carte cadeau"
        case .mealVoucher:  return "Titres restaurant"
        case .investment:   return "Investissement"
        case .cash:         return "Espèces"
        case .other:        return "Autre"
        }
    }

    /// Returns the SF Symbol name associated with the account category.
    var icon: String {
        switch self {
        case .checking:     return "banknote"
        case .savings:      return "piggybank"
        case .creditCard:   return "creditcard"
        case .crypto:       return "bitcoinsign.circle"
        case .giftCard:     return "gift"
        case .mealVoucher:  return "fork.knife"
        case .investment:   return "chart.line.uptrend.xyaxis"
        case .cash:         return "dollarsign.circle"
        case .other:        return "ellipsis.circle"
        }
    }
}
