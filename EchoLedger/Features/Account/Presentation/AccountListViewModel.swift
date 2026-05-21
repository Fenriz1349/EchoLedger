//
//  AccountListViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation
import Toasty

/// Manages the grouped list of accounts by institution and handles archive operations.
@MainActor
@Observable
final class AccountListViewModel {

    var accounts: [Account] = []
    var archivedAccounts: [Account] = []
    var institutions: [Institution] = []
    var isLoading = false

    /// Returns institutions paired with their active accounts, for grouped display.
    var institutionsWithAccounts: [(institution: Institution, accounts: [Account])] {
        institutions.compactMap { institution in
            let active = accounts.filter { $0.institutionId == institution.id }
            return active.isEmpty ? nil : (institution, active)
        }
    }

    /// Returns institutions paired with their archived accounts, for the collapsible section.
    var institutionsWithArchivedAccounts: [(institution: Institution, accounts: [Account])] {
        institutions.compactMap { institution in
            let archived = archivedAccounts.filter { $0.institutionId == institution.id }
            return archived.isEmpty ? nil : (institution, archived)
        }
    }

    private let toasty: ToastyManager
    private let getInstitutions: GetInstitutions
    private let getAccounts: GetAccounts
    private let archiveAccount: ArchiveAccount
    private let userId: UUID

    /// - Parameters:
    ///   - toasty: Toaster to display message to user.
    ///   - getInstitutions: UseCase for fetching institutions.
    ///   - getAccounts: UseCase for fetching accounts per institution.
    ///   - userId: The identifier of the current user.
    init(
        toasty: ToastyManager,
        getInstitutions: GetInstitutions,
        getAccounts: GetAccounts,
        archiveAccount: ArchiveAccount,
        userId: UUID) {
            self.toasty = toasty
            self.getInstitutions = getInstitutions
            self.getAccounts = getAccounts
            self.archiveAccount = archiveAccount
            self.userId = userId
        }

    /// Loads all institutions with their associated accounts.
    func load() async {
        isLoading = true

        do {
            let institutions = try await getInstitutions.execute(for: userId)
            self.institutions = institutions

            var allActive: [Account] = []
            var allArchived: [Account] = []

            for institution in institutions {
                let active = try await getAccounts.execute(for: institution.id, filter: .active)
                let archived = try await getAccounts.execute(for: institution.id, filter: .archived)
                allActive.append(contentsOf: active)
                allArchived.append(contentsOf: archived)
            }

            self.accounts = allActive
            self.archivedAccounts = allArchived
        } catch {
            toasty.showError(error)
        }

        isLoading = false
    }

    /// Archives an account and reloads the list.
    func archive(_ account: Account) async {
        do {
            try await archiveAccount.execute(id: account.id)
            await load()
        } catch {
            toasty.showError(error)
        }
    }
}
