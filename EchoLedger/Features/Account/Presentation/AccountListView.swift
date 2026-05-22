//
//  AccountListView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI
import CustomLabels

/// Displays accounts grouped by institution, with an add button and a collapsible archived section.
struct AccountListView: View {

    let coordinator: AppCoordinator
    @State private var sheet: AccountSheet?
    @State private var showTransferForm = false

    var body: some View {
        NavigationStack {
            Group {
                if coordinator.accountListViewModel.isLoading {
                    EchoLedgerLoader().frame(width: 80, height: 80)
                } else {
                    List {
                        AccountGroupList(
                            items: coordinator.accountListViewModel.institutionsWithAccounts,
                            balances: coordinator.accountListViewModel.balances,
                            onEdit: { sheet = .edit($0) },
                            onArchive: { account in Task { await coordinator.accountListViewModel.archive(account) } }
                        )

                        Section {
                            Button { sheet = .add } label: {
                                CustomButtonLabel(iconLeading: "plus",
                                                  message: "Ajouter un compte",
                                                  color: .accentColor,
                                                  isSelected: true)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal)

                            Button { showTransferForm = true } label: {
                                CustomButtonLabel(iconLeading: "arrow.left.arrow.right",
                                                  message: "Effectuer un transfert",
                                                  color: .accentColor,
                                                  isSelected: false)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal)
                        }

                        if !coordinator.accountListViewModel.archivedAccounts.isEmpty {
                            Section {
                                let count = coordinator.accountListViewModel.archivedAccounts.count
                                DisclosureGroup("Comptes archivés (\(count))") {
                                    AccountGroupList(
                                        items: coordinator.accountListViewModel.institutionsWithArchivedAccounts,
                                        balances: coordinator.accountListViewModel.balances,
                                        onEdit: { sheet = .edit($0) },
                                        onArchive: nil
                                    )
                                }
                            }
                        }
                    }
                    .refreshable {
                        await coordinator.accountListViewModel.load()
                    }
                }
            }
            .navigationTitle("Comptes")
            .navigationDestination(for: Account.self) { account in
                AccountDetailView(account: account, coordinator: coordinator)
                    .onDisappear {
                        Task { await coordinator.accountListViewModel.load() }
                    }
            }
            .sheet(isPresented: $showTransferForm) {
                TransferFormView(viewModel: coordinator.makeTransferFormViewModel())
            }
            .onChange(of: showTransferForm) {
                if !showTransferForm {
                    Task { await coordinator.accountListViewModel.load() }
                }
            }
            .sheet(item: $sheet) { sheet in
                switch sheet {
                case .add:
                    AccountFormView(viewModel: coordinator.makeAccountFormViewModel())
                case .edit(let account):
                    AccountFormView(viewModel: coordinator.makeAccountFormViewModel(existing: account))
                }
            }
            .onChange(of: sheet) {
                if sheet == nil {
                    Task { await coordinator.accountListViewModel.load() }
                }
            }
            .task {
                await coordinator.accountListViewModel.load()
            }
        }
    }
}

#Preview {
    AccountListView(coordinator: PreviewHelpers.appCoordinator)
        .environment(PreviewHelpers.container)
}
