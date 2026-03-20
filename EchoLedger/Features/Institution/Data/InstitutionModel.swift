//
//  InstitutionModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/03/2026.
//

import Foundation
import SwiftData

/// SwiftData persistent model for Institution.
/// Maps to and from the Domain Institution entity via InstitutionLocalDataSource.
@Model
final class InstitutionModel {

    // MARK: Properties
    var id: UUID
    var userId: UUID
    var name: String
    var type: String
    var logoURL: String?

    // MARK: Relationships
    @Relationship(deleteRule: .cascade)
    var accounts: [AccountModel]

    // MARK: Init
    /// Creates a new InstitutionModel from a Domain Institution entity.
    init(
        id: UUID = UUID(),
        userId: UUID,
        name: String,
        type: String,
        logoURL: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.type = type
        self.logoURL = logoURL
        self.accounts = []
    }

    // MARK: Mapping
    /// Converts this SwiftData model to a Domain Institution entity.
    func toDomain() -> Institution? {
        guard let institutionType = InstitutionType(rawValue: type) else { return nil }
        return Institution(
            id: id,
            userId: userId,
            name: name,
            type: institutionType,
            logoURL: logoURL
        )
    }

    /// Updates this model's properties from a Domain Institution entity.
    /// - Parameter institution: The domain entity with updated values.
    func update(from institution: Institution) {
        self.name = institution.name
        self.type = institution.type.rawValue
        self.logoURL = institution.logoURL
    }
}
