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
    var balances: [UUID: Double] = [:]
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
    private let unarchiveAccount: UnarchiveAccount
    private let getAccountBalance: GetAccountBalance
    private let userId: UUID

    /// - Parameters:
    ///   - toasty: Toaster to display message to user.
    ///   - getInstitutions: UseCase for fetching institutions.
    ///   - getAccounts: UseCase for fetching accounts per institution.
    ///   - archiveAccount: UseCase for archiving an account.
    ///   - unarchiveAccount: UseCase for restoring an archived account.
    ///   - getAccountBalance: UseCase for computing an account balance.
    ///   - userId: The identifier of the current user.
    init(
        toasty: ToastyManager,
        getInstitutions: GetInstitutions,
        getAccounts: GetAccounts,
        archiveAccount: ArchiveAccount,
        unarchiveAccount: UnarchiveAccount,
        getAccountBalance: GetAccountBalance,
        userId: UUID) {
            self.toasty = toasty
            self.getInstitutions = getInstitutions
            self.getAccounts = getAccounts
            self.archiveAccount = archiveAccount
            self.unarchiveAccount = unarchiveAccount
            self.getAccountBalance = getAccountBalance
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

            var newBalances: [UUID: Double] = [:]
            for account in allActive + allArchived {
                newBalances[account.id] = (try? await getAccountBalance.execute(
                    accountId: account.id, userId: userId)) ?? 0
            }
            self.balances = newBalances
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

    /// Restores an archived account to active status and reloads the list.
    func unarchive(_ account: Account) async {
        do {
            try await unarchiveAccount.execute(id: account.id)
            await load()
        } catch {
            toasty.showError(error)
        }
    }
}
