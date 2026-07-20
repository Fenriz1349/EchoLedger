//
//  GetAccountsWithInstitution.swift
//  EchoLedger
//
//  Created by Julien Cotte on 29/05/2026.
//

import Foundation

/// Fetches all accounts for a user across every institution and pairs each one
/// with its institution name, returning a flat sorted list of AccountDisplayItem.
/// Centralises the institution + account loading loop that was duplicated across ViewModels.
final class GetAccountsWithInstitution {

    private let getInstitutions: GetInstitutions
    private let getAccounts: GetAccounts

    init(getInstitutions: GetInstitutions, getAccounts: GetAccounts) {
        self.getInstitutions = getInstitutions
        self.getAccounts = getAccounts
    }

    /// - Parameters:
    ///   - userId: The identifier of the current user.
    ///   - filter: Whether to return active accounts only, archived only, or all.
    /// - Returns: A flat list of AccountDisplayItem sorted alphabetically by account name.
    func execute(for userId: UUID, filter: AccountFilter) async throws -> [AccountDisplayItem] {
        let institutions = try await getInstitutions.execute(for: userId)
        var result: [AccountDisplayItem] = []
        for institution in institutions {
            let accounts = try await getAccounts.execute(for: institution.id, filter: filter)
            for account in accounts {
                result.append(AccountDisplayItem(account: account, institutionName: institution.name))
            }
        }
        return result.sorted { $0.account.name < $1.account.name }
    }
}
