//
//  UpdateAccountInput.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation

/// Encapsulates all parameters required to update an existing account.
struct UpdateAccountInput {
    let id: UUID
    let institutionId: UUID
    let name: String
    let type: AccountType
}
