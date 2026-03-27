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
            ZStack {
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

                                Text("\(item.totalAmount)")
                                    .foregroundStyle(item.isExpense ? Color.primary : Color.green)
                                    .fontWeight(item.isExpense ? .regular : .semibold)
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
