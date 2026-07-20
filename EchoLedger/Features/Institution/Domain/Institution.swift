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

    let id: UUID
    let userId: UUID
    let name: String
    let category: InstitutionCategory
    let logoURL: String?
    /// Whether this institution has been archived by the user.
    let isArchived: Bool
    /// Date of the last local modification. Nil for records created before sync was introduced.
    let updatedAt: Date?

    /// Creates a new Institution.
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - userId: The identifier of the user this institution belongs to.
    ///   - name: Human-readable name of the institution (e.g. "Caisse d'Épargne").
    ///   - category: Category of the institution.
    ///   - logoURL: Optional URL string pointing to the institution's logo.
    ///   - isArchived: Whether the institution is archived. Defaults to false.
    ///   - updatedAt: Last modification date. Nil for legacy records.
    init(
        id: UUID = UUID(),
        userId: UUID,
        name: String,
        category: InstitutionCategory,
        logoURL: String? = nil,
        isArchived: Bool = false,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.category = category
        self.logoURL = logoURL
        self.isArchived = isArchived
        self.updatedAt = updatedAt
    }
}
