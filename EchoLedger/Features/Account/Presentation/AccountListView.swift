//
//  AccountListView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI

struct AccountListView: View {

    @State var viewModel: AccountListViewModel
    @Environment(DIContainer.self) private var container
    @State private var selectedAccount: Account?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.institutionsWithAccounts.isEmpty {
                    Text("Aucun compte — ajoutez-en un avec le bouton +")
                        .foregroundStyle(.secondary)
                } else {
                    List {
                        ForEach(viewModel.institutionsWithAccounts, id: \.institution.id) { item in
                            Section(item.institution.name) {
                                ForEach(item.accounts) { account in
                                    AccountRowView(
                                        account: account,
                                        onEdit: { selectedAccount = account },
                                        onArchive: { Task { await viewModel.archive(account) } }
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
                    viewModel.showAccountForm = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $selectedAccount) { account in
            AccountFormView(viewModel: container.makeAccountFormViewModel(existing: account))
        }
        .task {
            await viewModel.load()
        }
        .onChange(of: viewModel.showAccountForm) {
            if !viewModel.showAccountForm {
                Task { await viewModel.load() }
            }
        }
    }
}

#Preview {
    AccountListView(viewModel: PreviewHelpers.makeAccountListViewModel())
        .environment(PreviewHelpers.container)
}
