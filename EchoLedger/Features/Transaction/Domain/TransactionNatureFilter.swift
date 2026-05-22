//
//  TransactionNatureFilter.swift
//  EchoLedger
//
//  Created by Julien Cotte on 22/05/2026.
//

import Foundation

/// Filters transactions by their financial nature: expense, income, or transfer.
/// Used in `TransactionListViewModel` to narrow the displayed list.
enum TransactionNatureFilter: CaseIterable, Identifiable {
    case all
    case expense
    case income
    case transfer

    var id: Self { self }

    var label: String {
        switch self {
        case .all:      return "Tous"
        case .expense:  return "Dépenses"
        case .income:   return "Revenus"
        case .transfer: return "Virements"
        }
    }

    var icon: String {
        switch self {
        case .all:      return "tray.full"
        case .expense:  return "arrow.down.backward"
        case .income:   return "arrow.up.forward"
        case .transfer: return "arrow.left.arrow.right"
        }
    }
}
