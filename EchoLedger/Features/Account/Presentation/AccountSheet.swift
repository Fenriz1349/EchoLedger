//
//  AccountSheet.swift
//  EchoLedger
//
//  Created by Julien Cotte on 10/04/2026.
//

import Foundation

/// The modal sheets reachable from AccountListView.
/// Single source of truth driving one `sheet(item:)`, so the presentations never conflict.
enum AccountSheet: Identifiable, Equatable {
    case add
    case edit(Account)
    case transfer
    case editInstitution(Institution)

    /// Unique identifier used by SwiftUI's sheet(item:) to distinguish between sheets.
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let account): return account.id.uuidString
        case .transfer: return "transfer"
        case .editInstitution(let institution): return "institution-\(institution.id.uuidString)"
        }
    }
}
