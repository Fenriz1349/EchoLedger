//
//  DeletedEntityLocalSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 29/07/2026.
//

import Foundation
import SwiftData

/// Handles all SwiftData read and write operations for the DeletedEntities feature.
final class DeletedEntityLocalSource {

    private let context: ModelContext

    /// - Parameter context: The SwiftData model context used for persistence.
    init(context: ModelContext) {
        self.context = context
    }

    /// Fetches a deleted entity's trace by its original identifier.
    /// - Parameter id: The identifier the entity had before being deleted.
    /// - Returns: The matching Domain DeletedEntity entity, or `nil` if none exists.
    func fetch(by id: UUID) throws -> DeletedEntity? {
        var descriptor = FetchDescriptor<DeletedEntityModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first?.toDomain()
    }

    /// Persists a new deleted-entity trace locally.
    /// - Parameter entity: The domain DeletedEntity to save.
    func save(_ entity: DeletedEntity) throws {
        let model = DeletedEntityModel(id: entity.id, name: entity.name, kind: entity.kind.rawValue)
        context.insert(model)
        try context.save()
    }

    /// Permanently removes every deleted-entity trace from local storage.
    func purge() throws {
        try context.delete(model: DeletedEntityModel.self)
        try context.save()
    }
}
