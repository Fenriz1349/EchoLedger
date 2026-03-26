//
//  AccountListViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation

@MainActor
@Observable
final class AccountListViewModel {

    var institutionsWithAccounts: [(institution: Institution, accounts: [Account])] = []
    var isLoading = false
    var errorMessage: String? = nil
    var showAddAccount = false

    private let getInstitutions: GetInstitutions
    private let getAccounts: GetAccounts
    private let userId: UUID

    /// - Parameters:
    ///   - getInstitutions: UseCase for fetching institutions.
    ///   - getAccounts: UseCase for fetching accounts per institution.
    ///   - userId: The identifier of the current user.
    init(getInstitutions: GetInstitutions, getAccounts: GetAccounts, userId: UUID) {
        self.getInstitutions = getInstitutions
        self.getAccounts = getAccounts
        self.userId = userId
    }

    /// Loads all institutions with their associated accounts.
    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let institutions = try await getInstitutions.execute(for: userId)
            var result: [(institution: Institution, accounts: [Account])] = []
            for institution in institutions {
                let accounts = try await getAccounts.execute(for: institution.id)
                result.append((institution: institution, accounts: accounts))
            }
            institutionsWithAccounts = result
        } catch {
            errorMessage = "Impossible de charger les comptes"
        }
        isLoading = false
    }
}
