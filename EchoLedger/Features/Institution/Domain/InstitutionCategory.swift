//
//  InstitutionCategory.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

/// Represents the category of a financial institution.
/// RawValue is used for Firebase persistence, name is used for display.
enum InstitutionCategory: String, CaseIterable, Codable, Sendable {
    case bank
    case insurance
    case broker
    case mealVoucher
    case retailStore
    case cash
    case other

    /// Returns the French display name for the institution category.
    var name: String {
        switch self {
        case .bank:         return "Banque"
        case .insurance:    return "Assurance"
        case .broker:       return "Courtier"
        case .mealVoucher:  return "Titres restaurant"
        case .retailStore:  return "Enseigne commerciale"
        case .cash:         return "Espèces"
        case .other:        return "Autre"
        }
    }

    /// Returns the SF Symbol name associated with the institution category.
    var icon: String {
        switch self {
        case .bank:         return "building.columns"
        case .insurance:    return "shield"
        case .broker:       return "chart.line.uptrend.xyaxis"
        case .mealVoucher:  return "fork.knife"
        case .retailStore:  return "bag"
        case .cash:         return "banknote"
        case .other:        return "ellipsis.circle"
        }
    }
}
