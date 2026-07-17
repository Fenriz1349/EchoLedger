//
//  GetAccountsSortedByRecency.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/07/2026.
//

import Foundation

/// Fetches accounts paired with their institution, ordered by how recently each was used.
/// Composes GetAccountsWithInstitution and GetTransactions rather than querying repositories directly.
final class GetAccountsSortedByRecency {

    private let getAccountsWithInstitution: GetAccountsWithInstitution
    private let getTransactions: GetTransactions

    /// - Parameters:
    ///   - getAccountsWithInstitution: UseCase fetching accounts paired with their institution.
    ///   - getTransactions: UseCase fetching all of the user's transactions.
    init(getAccountsWithInstitution: GetAccountsWithInstitution, getTransactions: GetTransactions) {
        self.getAccountsWithInstitution = getAccountsWithInstitution
        self.getTransactions = getTransactions
    }

    /// - Parameters:
    ///   - userId: The identifier of the current user.
    ///   - filter: Whether to return active accounts only, archived only, or all.
    /// - Returns: Accounts ordered by most recently used first, then alphabetically.
    func execute(for userId: UUID, filter: AccountFilter) async throws -> [AccountDisplayItem] {
        let items = try await getAccountsWithInstitution.execute(for: userId, filter: filter)
        let transactions = try await getTransactions.execute(for: userId)
        return AccountRecencySorter.sort(items, using: transactions)
    }
}
