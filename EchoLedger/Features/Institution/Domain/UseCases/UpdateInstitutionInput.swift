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
    let type: InstitutionType
    let logoURL: String?

    /// Creates a new UpdateInstitutionInput.
    /// - Parameters:
    ///   - id: The unique identifier of the institution to update.
    ///   - userId: The identifier of the user this institution belongs to.
    ///   - name: Updated name. Must be between 2 and 50 characters.
    ///   - type: Updated category.
    ///   - logoURL: Updated optional logo URL.
    init(
        id: UUID,
        userId: UUID,
        name: String,
        type: InstitutionType,
        logoURL: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.type = type
        self.logoURL = logoURL
    }
}
