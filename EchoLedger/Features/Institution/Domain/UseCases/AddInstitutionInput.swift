//
//  AddInstitutionInput.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation

/// Encapsulates all parameters required to create a new institution.
struct AddInstitutionInput {
    let userId: UUID
    let name: String
    let type: InstitutionType
    let logoURL: String?
}
