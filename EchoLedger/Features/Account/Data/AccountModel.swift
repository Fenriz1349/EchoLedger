//
//  AccountModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/03/2026.
//

import Foundation
import SwiftData

/// SwiftData persistent model for Account.
/// Maps to and from the Domain Account entity via AccountLocalDataSource.
@Model
final class AccountModel {

    // MARK: Properties
    var id: UUID
    var institutionId: UUID
    var name: String
    var category: String

    // MARK: Init
    /// Creates a new AccountModel from primitive values.
    init(
        id: UUID = UUID(),
        institutionId: UUID,
        name: String,
        category: String
    ) {
        self.id = id
        self.institutionId = institutionId
        self.name = name
        self.category = category
    }

    // MARK: Mapping
    /// Converts this SwiftData model to a Domain Account entity.
    func toDomain() -> Account? {
        guard let accountCategory = AccountCategory(rawValue: category) else { return nil }
        return Account(
            id: id,
            institutionId: institutionId,
            name: name,
            category: accountCategory
        )
    }

    /// Updates this model's properties from a Domain Account entity.
    /// - Parameter account: The domain entity with updated values.
    func update(from account: Account) {
        self.name = account.name
        self.category = account.category.rawValue
    }
}
