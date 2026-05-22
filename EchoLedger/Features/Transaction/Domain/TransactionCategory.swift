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

    // MARK: Misc
    case gift

    // MARK: Income
    case salary
    case social
    case investment

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
        case .utilities:      return "Factures"
        case .health:         return "Santé"
        case .education:      return "Éducation"
        case .leisure:        return "Loisirs"
        case .shopping:       return "Shopping"
        case .travel:         return "Voyage"
        case .subscription:   return "Abonnements"
        case .gift:           return "Cadeaux & dons"
        case .salary:         return "Salaire"
        case .social:         return "Aides sociales"
        case .investment:     return "Investissement"
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

    /// Fixed color for charts. Avoids red and green — reserved for balance display.
    var color: Color {
        switch self {
        // Daily — warm orange/brown tones
        case .grocery:        return .orange
        case .restaurant:     return Color(red: 0.95, green: 0.65, blue: 0.10) // amber
        case .bar:            return .brown

        // Transport — blue sky / cyan
        case .transport:      return Color(red: 0.20, green: 0.65, blue: 0.90) // sky blue
        case .car:            return .cyan

        // Home & Life — deep indigo/purple/pink
        case .rent:           return .indigo
        case .utilities:      return Color(red: 0.40, green: 0.40, blue: 0.88) // periwinkle
        case .health:         return .pink
        case .education:      return .purple

        // Leisure — vivid but not garish
        case .leisure:        return Color(red: 0.65, green: 0.25, blue: 0.90) // violet
        case .shopping:       return Color(red: 0.95, green: 0.42, blue: 0.18) // coral
        case .travel:         return Color(red: 0.00, green: 0.72, blue: 0.72) // aqua
        case .subscription:   return Color(red: 0.50, green: 0.32, blue: 0.78) // mauve

        // Misc
        case .gift:           return Color(red: 0.95, green: 0.38, blue: 0.65) // hot pink
        case .other:          return .gray
        case .initialBalance: return Color(white: 0.60)
        case .transfer:       return Color(white: 0.55)

        // Income — cool blue/teal/mint
        case .salary:         return .blue
        case .social:         return .teal
        case .investment:     return .mint
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
        case .gift:           return "gift"
        case .salary:         return "banknote"
        case .social:         return "person.2"
        case .investment:     return "chart.line.uptrend.xyaxis"
        case .other:          return "ellipsis.circle"
        case .initialBalance: return "flag"
        case .transfer:       return "arrow.left.arrow.right"
        }
    }
}
