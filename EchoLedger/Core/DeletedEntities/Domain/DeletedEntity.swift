//
//  DeletedEntity.swift
//  EchoLedger
//
//  Created by Julien Cotte on 29/07/2026.
//

import Foundation

/// What kind of entity a `DeletedEntity` record stands in for.
enum DeletedEntityKind: String, Codable, Sendable {
    case account
    case institution
}

/// A lightweight trace kept after an account/institution is permanently deleted, so its name can
/// still be displayed (e.g. "Livret A (supprimé)") wherever its id is still referenced —
/// typically by a transaction split that was intentionally kept rather than destroyed.
struct DeletedEntity: Identifiable, Equatable, Codable, Sendable {

    let id: UUID
    let name: String
    let kind: DeletedEntityKind
    /// The institution's name at the time of deletion, captured only for `.account` — its
    /// institution may still exist, but the account no longer does to join against it.
    let institutionName: String?

    init(id: UUID, name: String, kind: DeletedEntityKind, institutionName: String? = nil) {
        self.id = id
        self.name = name
        self.kind = kind
        self.institutionName = institutionName
    }
}
