//
//  AccountLocalSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation
import SwiftData

// MARK: - AccountLocalSource
/// Handles all SwiftData read and write operations for the Account feature.
final class AccountLocalSource {

    private let context: ModelContext

    /// - Parameter context: The SwiftData model context used for persistence.
    init(context: ModelContext) {
        self.context = context
    }

    // MARK: Read

    /// Fetches all accounts belonging to a given institution.
    /// - Parameter institutionId: The internal UUID of the institution.
    /// - Returns: An array of Domain Account entities ordered by name.
    func fetchAll(for institutionId: UUID) throws -> [Account] {
        let descriptor = FetchDescriptor<AccountModel>(
            predicate: #Predicate { $0.institutionId == institutionId },
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor).compactMap { $0.toDomain() }
    }

    /// Fetches all active (non-archived) accounts belonging to a given institution.
    /// - Parameter institutionId: The identifier of the institution.
    /// - Returns: An array of active accounts ordered by name.
    /// - Throws: `AccountError` if the fetch fails.
    func fetchAllActive(for institutionId: UUID) throws -> [Account] {
        let descriptor = FetchDescriptor<AccountModel>(
            predicate: #Predicate { $0.institutionId == institutionId && !$0.isArchived },
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor).compactMap { $0.toDomain() }
    }

    /// Fetches all archived accounts belonging to a given institution.
    /// - Parameter institutionId: The identifier of the institution.
    /// - Returns: An array of archived accounts ordered by name.
    /// - Throws: `AccountError` if the fetch fails.
    func fetchAllArchived(for institutionId: UUID) throws -> [Account] {
        let descriptor = FetchDescriptor<AccountModel>(
            predicate: #Predicate { $0.institutionId == institutionId && $0.isArchived },
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor).compactMap { $0.toDomain() }
    }

    /// Fetches a single account by its internal identifier.
    /// - Parameter id: The internal UUID of the account.
    /// - Returns: The matching Domain Account entity.
    func fetch(by id: UUID) throws -> Account {
        var descriptor = FetchDescriptor<AccountModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let model = try context.fetch(descriptor).first else {
            throw AccountError.notFound
        }
        guard let account = model.toDomain() else {
            throw AccountError.notFound
        }
        return account
    }

    // MARK: Write

    /// Persists a new account locally.
    /// - Parameter account: The domain Account to save.
    func save(_ account: Account) throws {
        let model = AccountModel(
            id: account.id,
            institutionId: account.institutionId,
            name: account.name,
            category: account.category.rawValue
        )
        context.insert(model)
        try context.save()
    }

    /// Updates an existing account locally.
    /// - Parameter account: The domain Account with updated values.
    func update(_ account: Account) throws {
        let id = account.id
        var descriptor = FetchDescriptor<AccountModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let model = try context.fetch(descriptor).first else {
            throw AccountError.notFound
        }
        model.update(from: account)
        try context.save()
    }

    /// Inserts a new account locally if it does not exist, or updates it if it does.
    /// - Parameter account: The domain Account to insert or update.
    /// - Throws: A SwiftData error if the operation fails.
    func upsert(_ account: Account) throws {
        let id = account.id
        var descriptor = FetchDescriptor<AccountModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        if let existing = try context.fetch(descriptor).first {
            existing.update(from: account)
        } else {
            context.insert(AccountModel(
                id: account.id,
                institutionId: account.institutionId,
                name: account.name,
                category: account.category.rawValue,
                isArchived: account.isArchived
            ))
        }
        try context.save()
    }
}
