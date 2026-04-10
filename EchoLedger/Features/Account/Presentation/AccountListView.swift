//
//  AccountListView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI

struct AccountListView: View {

    @Environment(DIContainer.self) private var container
    let coordinator: AppCoordinator
    @State private var selectedAccount: Account?
    @State private var sheet: AccountSheet?

    var body: some View {
        NavigationStack {
            Group {
                if coordinator.accountListViewModel.isLoading {
                    ProgressView()
                } else if coordinator.accountListViewModel.institutionsWithAccounts.isEmpty {
                    Text("Aucun compte — ajoutez-en un avec le bouton +")
                        .foregroundStyle(.secondary)
                } else {
                    List {
                        ForEach(coordinator.accountListViewModel.institutionsWithAccounts, id: \.institution.id) { item in
                            Section(item.institution.name) {
                                ForEach(item.accounts) { account in
                                    NavigationLink(value: account) {
                                        AccountRowView(
                                            account: account,
                                            onEdit: { sheet = .edit(account) },
                                            onArchive: { Task { await coordinator.accountListViewModel.archive(account) } }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Comptes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        sheet = .add
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: Account.self) { account in
                AccountDetailView(account: account, coordinator: coordinator)
                    .onDisappear {
                        Task { await coordinator.accountListViewModel.load() }
                    }
            }
            .sheet(item: $sheet) { sheet in
                switch sheet {
                case .add:
                    AccountFormView(
                        viewModel: container.makeAccountFormViewModel()
                    )
                case .edit(let account):
                    AccountFormView(
                        viewModel: container.makeAccountFormViewModel(existing: account)
                    )
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
