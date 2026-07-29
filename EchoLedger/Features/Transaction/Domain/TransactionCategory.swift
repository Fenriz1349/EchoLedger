//
//  TransactionCategory.swift
//  EchoLedger
//
//  Created by Julien Cotte on 11/03/2026.
//

import Foundation

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

    /// Whether this category appears in the transaction lists.
    /// An initial balance is account setup, shown and edited from its own account — not activity.
    var isListed: Bool {
        self != .initialBalance
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
