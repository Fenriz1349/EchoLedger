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

    var id: UUID
    var institutionId: UUID
    var name: String
    var category: String
    var isArchived: Bool
    var updatedAt: Date?

    /// Creates a new AccountModel from primitive values.
    init(id: UUID = UUID(),
         institutionId: UUID,
         name: String,
         category: String,
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

    /// Converts this SwiftData model to a Domain Account entity.
    func toDomain() -> Account? {
        guard let accountCategory = AccountCategory(rawValue: category) else { return nil }
        return Account(
            id: id,
            institutionId: institutionId,
            name: name,
            category: accountCategory,
            isArchived: isArchived,
            updatedAt: updatedAt
        )
    }

    /// Updates this model's properties from a Domain Account entity.
    /// - Parameter account: The domain entity with updated values.
    func update(from account: Account) {
        self.institutionId = account.institutionId
        self.name = account.name
        self.category = account.category.rawValue
        self.isArchived = account.isArchived
        self.updatedAt = account.updatedAt
    }
}
