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
    var showDeleteAlert = false
    var accountToDelete: Account?
    /// True while a load or refresh is running. Drives the branded overlay. Navigation no longer
    /// triggers loads (the data is pre-filled at launch), so this only fires on launch, an explicit
    /// refresh, or a data mutation — never on a plain screen change.
    private(set) var isLoading = false

    /// Returns institutions paired with their active accounts, for grouped display.
    var institutionsWithAccounts: [(institution: Institution, accounts: [Account])] {
        institutions.compactMap { institution in
            let active = accounts.filter { $0.belongs(to: institution.id) }
            return active.isEmpty ? nil : (institution, active)
        }
    }

    /// Returns institutions paired with their archived accounts, for the collapsible section.
    var institutionsWithArchivedAccounts: [(institution: Institution, accounts: [Account])] {
        institutions.compactMap { institution in
            let archived = archivedAccounts.filter { $0.belongs(to: institution.id) }
            return archived.isEmpty ? nil : (institution, archived)
        }
    }

    private let toasty: ToastyManager
    private let getInstitutions: GetInstitutions
    private let getAccounts: GetAccounts
    private let archiveAccount: ArchiveAccount
    private let unarchiveAccount: UnarchiveAccountRule
    private let deleteAccount: DeleteAccountRule
    private let getAccountBalance: GetAccountBalance
    private let refreshFromRemote: RefreshFromRemote
    private let userId: UUID

    /// - Parameters:
    ///   - toasty: Toaster to display message to user.
    ///   - getInstitutions: UseCase for fetching institutions.
    ///   - getAccounts: UseCase for fetching accounts per institution.
    ///   - archiveAccount: UseCase for archiving an account.
    ///   - unarchiveAccount: UseCase for restoring an archived account.
    ///   - deleteAccount: UseCase for permanently deleting an account and its transactions.
    ///   - getAccountBalance: UseCase for computing an account balance.
    ///   - refreshFromRemote: UseCase warming the remote data before a user-triggered reload.
    ///   - userId: The identifier of the current user.
    init(
        toasty: ToastyManager,
        getInstitutions: GetInstitutions,
        getAccounts: GetAccounts,
        archiveAccount: ArchiveAccount,
        unarchiveAccount: UnarchiveAccountRule,
        deleteAccount: DeleteAccountRule,
        getAccountBalance: GetAccountBalance,
        refreshFromRemote: RefreshFromRemote,
        userId: UUID) {
            self.toasty = toasty
            self.getInstitutions = getInstitutions
            self.getAccounts = getAccounts
            self.archiveAccount = archiveAccount
            self.unarchiveAccount = unarchiveAccount
            self.deleteAccount = deleteAccount
            self.getAccountBalance = getAccountBalance
            self.refreshFromRemote = refreshFromRemote
            self.userId = userId
        }

    /// Loads all institutions with their associated accounts.
    func load() async {
        isLoading = true
        defer { isLoading = false }
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
    }

    /// Pulls fresh data from the remote backend, then reloads the list from the warmed cache.
    /// Triggered by an explicit user action (pull-to-refresh). A failed remote pull surfaces a
    /// toast but still reloads whatever the cache holds.
    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await refreshFromRemote.execute()
        } catch {
            toasty.showError(error)
        }
        await load()
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

    /// Permanently deletes the account and all its linked transactions.
    func delete(_ account: Account) async {
        do {
            try await deleteAccount.execute(id: account.id)
            await load()
            toasty.showSuccess("Compte supprimé.")
        } catch {
            toasty.showError(error)
        }
    }
}
