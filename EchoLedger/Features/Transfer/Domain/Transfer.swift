//
//  Transfer.swift
//  EchoLedger
//
//  Created by Julien Cotte on 22/05/2026.
//

import Foundation

/// Represents an internal transfer between two accounts.
/// A transfer is always composed of two linked transactions:
///   - `source` debits the source account
///   - `destination` credits the destination account
/// Both share the same label, amount and date, and are tagged `.transfer`.
struct Transfer: Identifiable, Equatable, Hashable {

    let source: Transaction
    let destination: Transaction

    var id: UUID { source.id }
    var amount: Double { source.totalAmount }
    var date: Date { source.date }
    var label: String { source.label }

    /// Resolves the source account display name from a pre-fetched names dictionary.
    func sourceName(from accountNames: [UUID: String]) -> String {
        source.splits.first.flatMap { accountNames[$0.accountId] } ?? "—"
    }

    /// Resolves the destination account display name from a pre-fetched names dictionary.
    func destinationName(from accountNames: [UUID: String]) -> String {
        destination.splits.first.flatMap { accountNames[$0.accountId] } ?? "—"
    }
}
