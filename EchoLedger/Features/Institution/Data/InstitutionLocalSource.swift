//
//  InstitutionLocalSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation
import SwiftData

/// Handles all SwiftData read and write operations for the Institution feature.
final class InstitutionLocalSource {

    private let context: ModelContext

    /// - Parameter context: The SwiftData model context used for persistence.
    init(context: ModelContext) {
        self.context = context
    }

    // MARK: Read

    /// Fetches all institutions belonging to a given user.
    /// - Parameter userId: The internal UUID of the user.
    /// - Returns: An array of Domain Institution entities ordered by name.
    func fetchAll(for userId: UUID) throws -> [Institution] {
        let descriptor = FetchDescriptor<InstitutionModel>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor).compactMap { $0.toDomain() }
    }

    /// Fetches a single institution by its internal identifier.
    /// - Parameter id: The internal UUID of the institution.
    /// - Returns: The matching Domain Institution entity.
    func fetch(by id: UUID) throws -> Institution {
        var descriptor = FetchDescriptor<InstitutionModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let model = try context.fetch(descriptor).first else {
            throw InstitutionError.notFound
        }
        guard let institution = model.toDomain() else {
            throw InstitutionError.notFound
        }
        return institution
    }

    // MARK: Write

    /// Persists a new institution locally.
    /// - Parameter institution: The domain Institution to save.
    func save(_ institution: Institution) throws {
        let model = InstitutionModel(
            id: institution.id,
            userId: institution.userId,
            name: institution.name,
            category: institution.category.rawValue,
            logoURL: institution.logoURL,
            isArchived: institution.isArchived
        )
        context.insert(model)
        try context.save()
    }

    /// Updates an existing institution locally.
    /// - Parameter institution: The domain Institution with updated values.
    func update(_ institution: Institution) throws {
        let id = institution.id
        var descriptor = FetchDescriptor<InstitutionModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let model = try context.fetch(descriptor).first else {
            throw InstitutionError.notFound
        }
        model.update(from: institution)
        try context.save()
    }

    /// Marks an institution as archived locally.
    /// - Parameter id: The internal UUID of the institution to archive.
    func archive(by id: UUID) throws {
        var descriptor = FetchDescriptor<InstitutionModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let model = try context.fetch(descriptor).first else {
            throw InstitutionError.notFound
        }
        model.isArchived = true
        model.updatedAt = Date()
        try context.save()
    }

    /// Marks an institution as active (removes archived status) locally.
    /// - Parameter id: The internal UUID of the institution to unarchive.
    func unarchive(by id: UUID) throws {
        var descriptor = FetchDescriptor<InstitutionModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let model = try context.fetch(descriptor).first else {
            throw InstitutionError.notFound
        }
        model.isArchived = false
        model.updatedAt = Date()
        try context.save()
    }

    /// Deletes an institution and all its associated accounts from local storage.
    /// - Parameter id: The internal UUID of the institution to delete.
    func delete(by id: UUID) throws {
        let accountDescriptor = FetchDescriptor<AccountModel>(
            predicate: #Predicate { $0.institutionId == id }
        )
        try context.fetch(accountDescriptor).forEach { context.delete($0) }

        var descriptor = FetchDescriptor<InstitutionModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let model = try context.fetch(descriptor).first else {
            throw InstitutionError.notFound
        }
        context.delete(model)
        try context.save()
    }

    /// Inserts a new institution locally if it does not exist, or updates it if it does.
    /// - Parameter institution: The domain Institution to insert or update.
    func upsert(_ institution: Institution) throws {
        let id = institution.id
        var descriptor = FetchDescriptor<InstitutionModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        if let existing = try context.fetch(descriptor).first {
            existing.update(from: institution)
        } else {
            context.insert(InstitutionModel(
                id: institution.id,
                userId: institution.userId,
                name: institution.name,
                category: institution.category.rawValue,
                logoURL: institution.logoURL,
                isArchived: institution.isArchived
            ))
        }
        try context.save()
    }
}
