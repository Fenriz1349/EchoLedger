//
//  TransactionCategory.swift
//  EchoLedger
//
//  Created by Julien Cotte on 11/03/2026.
//

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
        }
    }
}
