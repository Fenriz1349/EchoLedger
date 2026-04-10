//
//  AccountSheet.swift
//  EchoLedger
//
//  Created by Julien Cotte on 10/04/2026.
//

import Foundation

enum AccountSheet: Identifiable, Equatable {
    case add
    case edit(Account)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let account): return account.id.uuidString
        }
    }
}
