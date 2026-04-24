//
//  UserLocalSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation
import SwiftData

/// Handles all SwiftData read and write operations for the User feature.
final class UserLocalSource {

    // MARK: Properties
    private let context: ModelContext

    // MARK: Init
    /// - Parameter context: The SwiftData model context used for persistence.
    init(context: ModelContext) {
        self.context = context
    }

    // MARK: Read

    /// Fetches the first user stored locally.
    /// - Returns: The current local User domain entity.
    func fetchCurrent() throws -> User {
        let descriptor = FetchDescriptor<UserModel>()
        let results = try context.fetch(descriptor)
        guard let model = results.first else {
            throw UserError.notFound
        }
        return model.toDomain()
    }

    // MARK: Write

    /// Persists a new user locally.
    /// - Parameter user: The domain User to save.
    func save(_ user: User) throws {
        let model = UserModel(
            id: user.id,
            displayName: user.displayName,
            email: user.email,
            photoURL: user.photoURL
        )
        context.insert(model)
        try context.save()
    }

    /// Updates an existing user locally.
    /// - Parameter user: The domain User with updated values.
    func update(_ user: User) throws {
        let id = user.id
        var descriptor = FetchDescriptor<UserModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let model = try context.fetch(descriptor).first else {
            throw UserError.notFound
        }
        model.update(from: user)
        try context.save()
    }

    /// Deletes a user and all associated institutions, accounts, and transactions from local storage.
    /// - Parameter id: The internal UUID of the user to delete.
    func delete(by id: UUID) throws {
        let institutionDescriptor = FetchDescriptor<InstitutionModel>(
            predicate: #Predicate { $0.userId == id }
        )
        let institutions = try context.fetch(institutionDescriptor)
        for institution in institutions {
            let accountDescriptor = FetchDescriptor<AccountModel>(
                predicate: #Predicate { $0.institutionId == institution.id }
            )
            try context.fetch(accountDescriptor).forEach { context.delete($0) }
            context.delete(institution)
        }

        let transactionDescriptor = FetchDescriptor<TransactionModel>(
            predicate: #Predicate { $0.userId == id }
        )
        try context.fetch(transactionDescriptor).forEach { context.delete($0) }

        var descriptor = FetchDescriptor<UserModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let model = try context.fetch(descriptor).first else {
            throw UserError.notFound
        }
        context.delete(model)
        try context.save()
    }
}
