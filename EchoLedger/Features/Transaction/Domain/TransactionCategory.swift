//
//  TransactionCategory.swift
//  EchoLedger
//
//  Created by Julien Cotte on 11/03/2026.
//

import SwiftUI

/// Represents the category of a transaction.
/// RawValue is used for Firebase and SwiftData persistence — never rename a case.
enum TransactionCategory: String, CaseIterable, Codable {

    // MARK: Daily
    case grocery
    case restaurant
    case bar

    // MARK: Transport
    case transport
    case car

    // MARK: Home & Life
    case rent
    case utilities
    case health
    case education

    // MARK: Leisure
    case leisure
    case shopping
    case travel
    case subscription

    // MARK: Income
    case salary
    case social
    case investment
    case sale

    // MARK: Misc
    case gift
    case other
    case initialBalance
    case transfer

    var name: String {
        switch self {
        case .grocery:        return "Courses"
        case .restaurant:     return "Restaurant"
        case .bar:            return "Bar"
        case .transport:      return "Transport"
        case .car:            return "Voiture"
        case .rent:           return "Loyer"
        case .utilities:      return "Énergie"
        case .health:         return "Santé"
        case .education:      return "Éducation"
        case .leisure:        return "Loisirs"
        case .shopping:       return "Shopping"
        case .travel:         return "Voyage"
        case .subscription:   return "Abonnements"
        case .salary:         return "Salaire"
        case .sale:           return "Ventes"
        case .social:         return "Aides sociales"
        case .investment:     return "Investissement"
        case .gift:           return "Cadeaux & dons"
        case .other:          return "Autre"
        case .initialBalance: return "Solde initial"
        case .transfer:       return "Transfert"
        }
    }

    /// Whether this category should appear in expense/income charts and reports.
    /// Transfers and initial balances are internal operations, not real financial events.
    var isReportable: Bool {
        self != .transfer && self != .initialBalance
    }

    /// Whether this category can be manually selected by the user in a transaction form.
    /// Transfers and initial balances are created via dedicated flows, not free-form entry.
    var isUserSelectable: Bool {
        self != .transfer && self != .initialBalance
    }

    /// Fixed color for charts. Avoids red and green — reserved for balance display.
    var color: Color {
        switch self {
        // Distinct hue per category — avoids pure red and green (reserved for balance display).
        case .grocery:        return Color(red: 0.05, green: 0.65, blue: 0.47) // teal
        case .restaurant:     return Color(red: 0.91, green: 0.35, blue: 0.05) // orange
        case .bar:            return Color(red: 0.61, green: 0.40, blue: 0.27) // brown
        case .transport:      return Color(red: 0.08, green: 0.67, blue: 0.75) // cyan
        case .car:            return Color(red: 0.36, green: 0.40, blue: 0.49) // slate
        case .rent:           return Color(red: 0.23, green: 0.36, blue: 0.86) // royal blue
        case .utilities:      return Color(red: 0.96, green: 0.62, blue: 0.00) // gold
        case .health:         return Color(red: 0.90, green: 0.29, blue: 0.50) // rose
        case .education:      return Color(red: 0.75, green: 0.29, blue: 0.86) // orchid
        case .leisure:        return Color(red: 0.44, green: 0.28, blue: 0.91) // violet
        case .shopping:       return Color(red: 0.97, green: 0.51, blue: 0.68) // pink
        case .travel:         return Color(red: 0.11, green: 0.49, blue: 0.84) // blue
        case .subscription:   return Color(red: 0.45, green: 0.56, blue: 0.99) // periwinkle
        case .gift:           return Color(red: 0.76, green: 0.15, blue: 0.36) // raspberry

        case .other:          return .gray
        case .initialBalance: return Color(white: 0.60)
        case .transfer:       return Color(white: 0.55)

        // Income — kept as-is (shown in a separate chart)
        case .salary:         return .blue
        case .social:         return .teal
        case .investment:     return .mint
        case .sale:           return Color(red: 0.98, green: 0.69, blue: 0.02) // amber
        }
    }

    var icon: String {
        switch self {
        case .grocery:        return "basket"
        case .restaurant:     return "fork.knife"
        case .bar:            return "wineglass"
        case .transport:      return "tram"
        case .car:            return "car"
        case .rent:           return "house"
        case .utilities:      return "bolt"
        case .health:         return "cross.case"
        case .education:      return "graduationcap"
        case .leisure:        return "gamecontroller"
        case .shopping:       return "bag"
        case .travel:         return "airplane"
        case .subscription:   return "repeat"
        case .salary:         return "banknote"
        case .sale:           return "tag"
        case .social:         return "person.2"
        case .investment:     return "chart.line.uptrend.xyaxis"
        case .gift:           return "gift"
        case .other:          return "ellipsis.circle"
        case .initialBalance: return "flag"
        case .transfer:       return "arrow.left.arrow.right"
        }
    }
}
