//
//  UpdateUserInput.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation

/// Encapsulates all parameters required to update a user's profile.
struct UpdateUserInput {
    let id: UUID
    let displayName: String
    let email: String
    let photoURL: String?
}
