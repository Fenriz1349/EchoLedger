//
//  AccountDetailView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 10/04/2026.
//

import SwiftUI
import CustomLabels

/// Shows the full details of an account, with actions to edit or archive it.
struct AccountDetailView: View {

    let account: Account
    let coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var showEditForm = false

    /// Always reflects the latest version of the account from the ViewModel.
    /// Falls back to the initial value if the account is not yet reloaded.
    private var currentAccount: Account {
        coordinator.accountListViewModel.accounts.first { $0.id == account.id } ?? account
    }

    var body: some View {
        List {
            Section("Informations") {
                LabeledContent("Nom", value: currentAccount.name)
                HStack {
                    Text("Catégorie")
                    Spacer()
                    Label(currentAccount.category.name, systemImage: currentAccount.category.icon)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                HStack(spacing: 12) {
                    Button {
                        showEditForm = true
                    } label: {
                        CustomButtonLabel(
                            iconLeading: "pencil",
                            message: "Modifier",
                            color: .blue
                        )
                    }
                    .buttonStyle(.plain)
                    Button {
                        Task {
                            await coordinator.accountListViewModel.archive(currentAccount)
                            dismiss()
                        }
                    } label: {
                        CustomButtonLabel(
                            iconLeading: "trash",
                            message: "Archiver",
                            color: .red
                        )
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .padding(.horizontal)
            }
        }
        .navigationTitle(currentAccount.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditForm) {
            AccountFormView(viewModel: coordinator.makeAccountFormViewModel(existing: currentAccount))
        }
        .onChange(of: showEditForm) {
            if !showEditForm {
                Task { await coordinator.accountListViewModel.load() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AccountDetailView(
            account: PreviewData.accountCourant,
            coordinator: PreviewHelpers.appCoordinator
        )
    }
    .environment(PreviewHelpers.container)
}
