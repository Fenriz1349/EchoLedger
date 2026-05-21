//
//  RecentTransactionsView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 21/05/2026.
//

import SwiftUI

/// Displays a short list of recent transactions for an account, inside a labeled section.
struct RecentTransactionsView: View {

    let transactionsList: [Transaction]
    let onEdit: (Transaction) -> Void
    let onDelete: (Transaction) -> Void

    var body: some View {
        Section("Dernières transactions") {
            ForEach(transactionsList) { transaction in
                TransactionRowView(
                    transaction: transaction,
                    onEdit: { onEdit(transaction) },
                    onDelete: { onDelete(transaction) }
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            RecentTransactionsView(
                transactionsList: PreviewData.transactions,
                onEdit: { _ in },
                onDelete: { _ in }
            )
        }
    }
}
