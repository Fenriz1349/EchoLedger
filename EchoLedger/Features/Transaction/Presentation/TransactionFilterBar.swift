//
//  TransactionFilterBar.swift
//  EchoLedger
//
//  Created by Julien Cotte on 22/05/2026.
//

import SwiftUI

/// Floating filter bar displayed as an overlay at the bottom of the transaction list.
/// Contains three pickers: nature (expense/income/transfer), category, and account.
/// The category picker is hidden when the nature filter is set to `.transfer`.
struct TransactionFilterBar: View {

    @Bindable var viewModel: TransactionListViewModel

    var body: some View {
        HStack(spacing: 8) {

            // MARK: Nature
            Menu {
                Picker("Nature", selection: $viewModel.selectedNature) {
                    ForEach(TransactionNatureFilter.allCases) { nature in
                        Text(nature.label).tag(nature)
                    }
                }
            } label: {
                FilterPill(
                    label: viewModel.selectedNature == .all ? "Nature" : viewModel.selectedNature.label,
                    isActive: viewModel.selectedNature != .all,
                    systemImage: viewModel.selectedNature.icon
                )
            }

            // MARK: Category (hidden for transfers)
            if viewModel.selectedNature != .transfer {
                Menu {
                    Picker("Catégorie", selection: $viewModel.selectedCategory) {
                        Text("Toutes").tag(Optional<TransactionCategory>.none)
                        ForEach(viewModel.availableCategories, id: \.self) { category in
                            Label(category.name, systemImage: category.icon).tag(Optional(category))
                        }
                    }
                } label: {
                    FilterPill(
                        label: viewModel.selectedCategory?.name ?? "Catégorie",
                        isActive: viewModel.selectedCategory != nil,
                        systemImage: viewModel.selectedCategory?.icon
                    )
                }
            }

            // MARK: Account
            Menu {
                Picker("Compte", selection: $viewModel.selectedAccountId) {
                    Text("Tous").tag(Optional<UUID>.none)
                    ForEach(viewModel.availableAccounts) { account in
                        Text(account.name).tag(Optional(account.id))
                    }
                }
            } label: {
                FilterPill(
                    label: viewModel.selectedAccountId
                        .flatMap { id in viewModel.availableAccounts.first { $0.id == id }?.name }
                        ?? "Compte",
                    isActive: viewModel.selectedAccountId != nil
                )
            }

            Spacer()

            // MARK: Reset
            if viewModel.hasActiveFilters {
                Button { viewModel.resetFilters() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 12, y: -2)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

#Preview {
    TransactionFilterBar(viewModel: PreviewHelpers.appCoordinator.transactionListViewModel)
        .environment(PreviewHelpers.container)
        .padding(.top, 300)
}
