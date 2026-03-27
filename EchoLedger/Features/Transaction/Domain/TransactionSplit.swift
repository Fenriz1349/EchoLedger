//
//  TransactionSplit.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Represents the allocation of a portion of a Transaction to a specific Account.
/// Acts as a join entity between Transaction and Account.
/// The sum of all splits for a given transaction must equal the transaction's totalAmount.
struct TransactionSplit: Identifiable, Equatable, Codable {

    // MARK: Properties
    let id: UUID
    let accountId: UUID
    let amount: Double

    // MARK: Init
    /// Creates a new TransactionSplit.
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - accountId: The identifier of the Account this split is allocated to.
    ///   - amount: The portion of the total transaction amount for this account. Must be positive.
    init(id: UUID = UUID(), accountId: UUID, amount: Double) {
        self.id = id
        self.accountId = accountId
        self.amount = amount
    }
}
