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

    var body: some View {
        NavigationStack {
            Group {
                List {
                    AccountGroupList(
                        items: coordinator.accountListViewModel.institutionsWithAccounts,
                        balances: coordinator.accountListViewModel.balances,
                        onEdit: { sheet = .edit($0) },
                        onArchive: { account in Task { await coordinator.accountListViewModel.archive(account) } },
                        onEditInstitution: { sheet = .editInstitution($0) }
                    )

                    VStack {
                        Button { sheet = .add } label: {
                            CustomButtonLabel(iconLeading: "plus",
                                              message: "Ajouter un compte",
                                              color: .accentColor,
                                              isSelected: false)
                        }
                        .buttonStyle(.borderless)

                        Button { sheet = .transfer } label: {
                            CustomButtonLabel(iconLeading: "arrow.left.arrow.right",
                                              message: "Ajouter un transfert",
                                              color: .accentColor,
                                              isSelected: false)
                        }
                        .buttonStyle(.borderless)
                    }
                    .listRowBackground(Color.clear)

                    if !coordinator.accountListViewModel.archivedAccounts.isEmpty {
                        Section {
                            let count = coordinator.accountListViewModel.archivedAccounts.count
                            DisclosureGroup("Comptes archivés (\(count))") {
                                AccountGroupList(
                                    items: coordinator.accountListViewModel.institutionsWithArchivedAccounts,
                                    balances: coordinator.accountListViewModel.balances,
                                    onEdit: { sheet = .edit($0) },
                                    onArchive: nil,
                                    onEditInstitution: { sheet = .editInstitution($0) }
                                )
                            }
                        }
                    }
                }
                .refreshable {
                    await coordinator.accountListViewModel.refresh()
                }
            }
            .navigationTitle("Comptes")
            .navigationDestination(for: Account.self) { account in
                AccountDetailView(account: account, coordinator: coordinator)
                    .onDisappear {
                        Task { await coordinator.accountListViewModel.load() }
                    }
            }
            .sheet(item: $sheet) { sheet in
                switch sheet {
                case .add:
                    AccountFormView(viewModel: coordinator.makeAccountFormViewModel())
                case .edit(let account):
                    AccountFormView(viewModel: coordinator.makeAccountFormViewModel(existing: account))
                case .transfer:
                    TransferFormView(viewModel: coordinator.makeTransferFormViewModel())
                case .editInstitution(let institution):
                    InstitutionFormView(viewModel: coordinator.makeInstitutionFormViewModel(existing: institution))
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
        .overlay {
            if coordinator.accountListViewModel.isLoading {
                EchoProgressView()
            }
        }
    }
}

#Preview {
    AccountListView(coordinator: PreviewHelpers.appCoordinator)
        .environment(PreviewHelpers.container)
}
