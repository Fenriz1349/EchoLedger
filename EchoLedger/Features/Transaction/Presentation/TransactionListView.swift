//
//  TransactionListView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI

struct TransactionListView: View {

    @State var viewModel: TransactionListViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.transactions.isEmpty {
                    Text("Aucune transaction pour le moment")
                        .foregroundStyle(.secondary)
                } else {
                    List {
                        ForEach(viewModel.transactions, id: \.id) { item in
                            HStack {
                                let name = item.category.icon
                                Image(systemName: name)
                                    .frame(width: 32)

                                VStack(alignment: .leading) {
                                    Text(item.label)
                                        .font(.body)
                                    Text(item.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(item.totalAmount.toEuro)
                                    .foregroundStyle(item.isExpense ? Color.primary : Color.green)
                                    .fontWeight(item.isExpense ? .regular : .semibold)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .confirm) {
                                    Task { showAddTransaction = true }
                                } label: {
                                    Label("Modifier", systemImage: "pencil")
                                }
                                    Button(role: .destructive) {
                                        Task { await viewModel.delete(item) }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("Transactions")
            .task {
                await viewModel.load()
            }
        }
    }
}

#Preview {
    TransactionListView(viewModel: PreviewHelpers.makeTransactionListViewModel())
        .environment(PreviewHelpers.container)
}
