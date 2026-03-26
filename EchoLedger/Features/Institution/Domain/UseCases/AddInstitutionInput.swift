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

    /// Creates a new AddInstitutionInput.
    /// - Parameters:
    ///   - userId: The identifier of the user this institution belongs to.
    ///   - name: Name of the institution. Must be between 2 and 50 characters.
    ///   - type: Category of the institution.
    ///   - logoURL: Optional URL string pointing to the institution's logo.
    init(
        userId: UUID,
        name: String,
        type: InstitutionType,
        logoURL: String? = nil
    ) {
        self.userId = userId
        self.name = name
        self.type = type
        self.logoURL = logoURL
    }
}
