//
//  AccountDetailView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 10/04/2026.
//

import SwiftUI
import CustomLabels

/// Shows the full details of an account: balance, recent transactions, charts, and archive toggle.
struct AccountDetailView: View {

    @State private var viewModel: AccountDetailViewModel
    let coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var showEditForm = false
    @State private var editTransaction: Transaction?
    @State private var selectedTransfer: Transfer?

    init(account: Account, coordinator: AppCoordinator) {
        self.coordinator = coordinator
        _viewModel = State(wrappedValue: coordinator.makeAccountDetailViewModel(account: account))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                EchoLedgerLoader().frame(width: 80, height: 80)
            } else {
                List {
                    // MARK: Balance
                    Section("Solde") {
                        HStack {
                            Text(viewModel.balance.toEuro)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(viewModel.balance >= 0 ? Color.green : Color.red)
                            Spacer()
                            Label(viewModel.account.category.name, systemImage: viewModel.account.category.icon)
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                    }

                    // MARK: Charts
                    if !viewModel.expenseChartData.isEmpty {
                        Section {
                            ExpensePieChartView(data: viewModel.expenseChartData)
                        }
                    }

                    if !viewModel.incomeChartData.isEmpty {
                        Section {
                            IncomePieChartView(data: viewModel.incomeChartData)
                        }
                    }

                    // MARK: Recent transactions
                    if !viewModel.recentItems.isEmpty {
                        RecentTransactionsView(
                            items: viewModel.recentItems,
                            accountNames: viewModel.accountNames,
                            onEdit: { editTransaction = $0 },
                            onDelete: { transaction in Task { await viewModel.delete(transaction) } },
                            onTapTransfer: { transfer in
                                selectedTransfer = transfer
                            },
                            onDeleteTransfer: { transfer in Task { await viewModel.deleteTransfer(transfer) } }
                        )
                    }
                }
            }
        }
        .navigationTitle(viewModel.account.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showEditForm = true } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .alert("Archiver ce compte ?", isPresented: $viewModel.showArchiveAlert) {
            Button("Archiver", role: .destructive) {
                Task { await viewModel.archive() }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Le compte sera masqué de la liste principale. Les transactions existantes restent accessibles.")
        }
        .navigationDestination(for: Transaction.self) { transaction in
            TransactionDetailView(transaction: transaction, coordinator: coordinator)
        }
        .sheet(isPresented: $showEditForm) {
            AccountFormView(viewModel: coordinator.makeAccountFormViewModel(existing: viewModel.account))
        }
        .sheet(item: $editTransaction) { transaction in
            TransactionFormView(viewModel: coordinator.makeTransactionFormViewModel(existing: transaction))
        }
        .onChange(of: showEditForm) {
            if !showEditForm {
                Task { await viewModel.load() }
            }
        }
        .onChange(of: editTransaction) {
            if editTransaction == nil {
                Task { await viewModel.load() }
            }
        }
        .sheet(item: $selectedTransfer) { transfer in
            TransferDetailView(transfer: transfer, coordinator: coordinator)
        }
        .onChange(of: selectedTransfer) {
            if selectedTransfer == nil {
                Task { await viewModel.load() }
            }
        }
        .task {
            viewModel.onNotFound = { dismiss() }
            await viewModel.load()
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
