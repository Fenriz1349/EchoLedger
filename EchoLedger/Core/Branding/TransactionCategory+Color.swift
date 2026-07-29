//
//  TransactionCategory+Color.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/07/2026.
//

import SwiftUI

extension TransactionCategory {

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
}
