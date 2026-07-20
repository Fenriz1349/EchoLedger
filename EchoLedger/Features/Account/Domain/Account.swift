//
//  Account.swift
//  EchoLedger
//
//  Created by Julien Cotte on 18/11/2025.
//

import Foundation

/// Represents a financial account belonging to an Institution.
/// Balance is not stored — it is computed on demand via GetAccountBalance.
struct Account: Identifiable, Equatable, Codable, Sendable, Hashable {

    let id: UUID
    let institutionId: UUID
    let name: String
    let category: AccountCategory
    let isArchived: Bool
    /// Date of the last local modification. Nil for records created before sync was introduced.
    let updatedAt: Date?

    /// Creates a new Account.
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - institutionId: The identifier of the institution this account belongs to.
    ///   - name: Human-readable name of the account (e.g. "Livret A").
    ///   - category: Category of the account.
    ///   - isArchived: Bool to archive an account.
    ///   - updatedAt: Last modification date. Nil for legacy records.
    init(
        id: UUID = UUID(),
        institutionId: UUID,
        name: String,
        category: AccountCategory,
        isArchived: Bool = false,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.institutionId = institutionId
        self.name = name
        self.category = category
        self.isArchived = isArchived
        self.updatedAt = updatedAt
    }
}

extension Account {

    /// True when the account belongs to the given institution.
    func belongs(to institutionId: UUID) -> Bool {
        self.institutionId == institutionId
    }
}
