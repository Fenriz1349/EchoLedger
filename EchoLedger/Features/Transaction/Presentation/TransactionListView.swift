//
//  TransactionListView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI

struct TransactionListView: View {

    @Environment(DIContainer.self) private var container
   let coordinator: AppCoordinator?

    var body: some View {
        NavigationStack {
            Group {
                if let coordinator {
                    if coordinator.transactionListViewModel.isLoading {
                        ProgressView()
                    } else if coordinator.transactionListViewModel.transactions.isEmpty {
                        Text("Aucune transaction pour le moment")
                            .foregroundStyle(.secondary)
                    } else {
                        List {
                            ForEach(coordinator.transactionListViewModel.transactions, id: \.id) { item in
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
                                    Button(role: .destructive) {
                                        Task { await coordinator.transactionListViewModel.delete(item) }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                    Button() {
                                        //                                    coordinator.transactionFormViewModel.existingTransaction = item
                                        coordinator.transactionListViewModel.showAddTransaction = true
                                    } label: {
                                        Label("Modifier", systemImage: "pencil")
                                    }
                                }
                            }
                        }
                    }
                }
            }.navigationTitle("Transactions")
            //            .sheet(isPresented: $coordinator.transactionListViewModel.showAddTransaction) {
            //                TransactionFormView(viewModel: coordinator.transactionFormViewModel)
            //            }
            
            //            .task {
            //                await coordinator.transactionListViewModel.load()
            //            }
        }
    }

}

//#Preview {
//    TransactionListView(/*coordinator: PreviewHelpers.makeAppCoordinator(),*/
//                        viewModel: PreviewHelpers.makeTransactionListViewModel())
//    .environment(PreviewHelpers.container)
//}
