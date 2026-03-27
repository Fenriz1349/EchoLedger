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
                                    HStack {
                                        Image(systemName: account.category.icon)
                                        Text(account.name)
                                        Spacer()
                                        Text(account.category.name)
                                            .foregroundStyle(.secondary)
                                            .font(.caption)
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
                        viewModel.showAddAccount = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddAccount) {
                AddAccountView(viewModel: container.makeAddAccountViewModel())
            }
            .task {
                await viewModel.load()
            }
            .onChange(of: viewModel.showAddAccount) {
                if !viewModel.showAddAccount {
                    Task { await viewModel.load() }
                }
            }
        }
    }
}

#Preview {
    let container = DIContainer.preview()
    return AccountListView(viewModel: container.makeAccountListViewModel())
        .environment(container)
}
