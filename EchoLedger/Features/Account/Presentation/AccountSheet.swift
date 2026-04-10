//
//  AccountSheet.swift
//  EchoLedger
//
//  Created by Julien Cotte on 10/04/2026.
//

import Foundation

/// Represents the possible modal sheets in AccountListView: adding a new account or editing an existing one.
enum AccountSheet: Identifiable, Equatable {
    case add
    case edit(Account)

    /// Unique identifier used by SwiftUI's sheet(item:) to distinguish between sheets.
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let account): return account.id.uuidString
        }
    }
}
