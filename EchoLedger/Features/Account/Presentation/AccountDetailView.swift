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

                    // MARK: Archive toggle
                    HStack {
                        Toggle("Compte \(viewModel.isArchived ?  "archivé" : "actif")", isOn: Binding<Bool>(
                            get: { viewModel.isArchived },
                            set: { newValue in
                                if newValue {
                                    viewModel.showArchiveAlert = true
                                } else {
                                    Task { await viewModel.unarchive() }
                                }
                            }
                        ))
                        .tint(.red)

                        Button { showEditForm = true } label: {
                            CustomButtonLabel(iconLeading: "pencil", message: "Modifier", color: .blue)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                        .padding(.horizontal)
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
                    if !viewModel.recentTransactions.isEmpty {
                        RecentTransactionsView(
                            transactionsList: viewModel.recentTransactions,
                            accountNames: viewModel.accountNames,
                            onEdit: { editTransaction = $0 },
                            onDelete: { transaction in Task { await viewModel.delete(transaction) } },
                            onDeleteTransfer: { expense, income in Task { await viewModel.deleteTransfer(expense: expense, income: income) } }
                        )
                    }
                }
            }
        }
        .navigationTitle(viewModel.account.name)
        .navigationBarTitleDisplayMode(.inline)
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
        .task {
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
