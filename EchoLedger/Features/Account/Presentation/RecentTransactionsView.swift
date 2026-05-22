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
    let accountNames: [UUID: String]
    let onEdit: (Transaction) -> Void
    let onDelete: (Transaction) -> Void
    let onDeleteTransfer: (Transaction, Transaction) -> Void

    var body: some View {
        Section("Dernières transactions") {
            ForEach(TransactionListItem.group(transactionsList)) { item in
                TransactionListItemView(
                    item: item,
                    accountNames: accountNames,
                    onEdit: onEdit,
                    onDelete: onDelete,
                    onDeleteTransfer: onDeleteTransfer
                )
            }
        }
    }
}

#Preview {
    let accountNames: [UUID: String] = PreviewData.accounts.reduce(into: [:]) { $0[$1.id] = $1.name }
    NavigationStack {
        List {
            RecentTransactionsView(
                transactionsList: PreviewData.transactions,
                accountNames: accountNames,
                onEdit: { _ in },
                onDelete: { _ in },
                onDeleteTransfer: { _, _ in }
            )
        }
    }
}
