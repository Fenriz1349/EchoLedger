//
//  UpdateInstitutionInput.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation

/// Encapsulates all parameters required to update an existing institution.
struct UpdateInstitutionInput {
    let id: UUID
    let userId: UUID
    let name: String
    let category: InstitutionCategory
    let logoURL: String?
}
