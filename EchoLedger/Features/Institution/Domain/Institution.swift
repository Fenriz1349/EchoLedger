//
//  Institution.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

/// Represents a financial institution belonging to a user.
/// An institution owns one or more accounts.
struct Institution: Identifiable, Equatable, Codable, Sendable, Hashable {

    // MARK: Properties
    let id: UUID
    let userId: UUID
    let name: String
    let type: InstitutionType
    let logoURL: String?

    // MARK: Init
    /// Creates a new Institution.
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - userId: The identifier of the user this institution belongs to.
    ///   - name: Human-readable name of the institution (e.g. "Caisse d'Épargne").
    ///   - type: Category of the institution.
    ///   - logoURL: Optional URL string pointing to the institution's logo.
    init(
        id: UUID = UUID(),
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
