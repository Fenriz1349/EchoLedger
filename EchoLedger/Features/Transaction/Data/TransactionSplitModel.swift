//
//  TransactionSplitModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/03/2026.
//

import Foundation
import SwiftData

/// SwiftData persistent model for TransactionSplit.
/// Embedded in TransactionModel via a cascade relationship.
@Model
final class TransactionSplitModel {

    var id: UUID
    var accountId: UUID
    var amount: Double

    /// Creates a new TransactionSplitModel from primitive values.
    init(
        id: UUID = UUID(),
        accountId: UUID,
        amount: Double
    ) {
        self.id = id
        self.accountId = accountId
        self.amount = amount
    }

    /// Converts this SwiftData model to a Domain TransactionSplit entity.
    func toDomain() -> TransactionSplit {
        TransactionSplit(
            id: id,
            accountId: accountId,
            amount: amount
        )
    }
}
