//
//  DeletedEntityModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 29/07/2026.
//

import Foundation
import SwiftData

/// SwiftData persistent model for DeletedEntity.
/// Maps to and from the Domain DeletedEntity entity via DeletedEntityLocalSource.
@Model
final class DeletedEntityModel {

    var id: UUID
    var name: String
    var kind: String

    /// Creates a new DeletedEntityModel from primitive values.
    init(id: UUID, name: String, kind: String) {
        self.id = id
        self.name = name
        self.kind = kind
    }

    /// Converts this SwiftData model to a Domain DeletedEntity entity.
    func toDomain() -> DeletedEntity? {
        guard let entityKind = DeletedEntityKind(rawValue: kind) else { return nil }
        return DeletedEntity(id: id, name: name, kind: entityKind)
    }
}
