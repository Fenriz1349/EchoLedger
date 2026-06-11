//
//  RecentTransactionsView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 21/05/2026.
//

import SwiftUI

/// Displays a short list of recent transactions for an account, inside a labeled section.
/// Receives already-grouped `TransactionListItem`s so transfer pairs are never broken by account filtering.
struct RecentTransactionsView: View {

    let items: [TransactionListItem]
    let accountNames: [UUID: String]
    let onEdit: (Transaction) -> Void
    let onDelete: (Transaction) -> Void
    let onTapTransfer: (Transfer) -> Void
    let onDeleteTransfer: (Transfer) -> Void
    let onEditTransfer: (Transfer) -> Void

    var body: some View {
        Section("Dernières transactions") {
            ForEach(items) { item in
                TransactionListItemView(
                    item: item,
                    accountNames: accountNames,
                    onEdit: onEdit,
                    onDelete: onDelete,
                    onTapTransfer: onTapTransfer,
                    onDeleteTransfer: onDeleteTransfer,
                    onEditTransfer: onEditTransfer
                )
            }
        }
    }
}

#Preview {
    let accountNames: [UUID: String] = PreviewData.accounts.reduce(into: [:]) { $0[$1.id] = $1.name }
    let items = TransactionListItem.group(PreviewData.transactions)
    NavigationStack {
        List {
            RecentTransactionsView(
                items: items,
                accountNames: accountNames,
                onEdit: { _ in },
                onDelete: { _ in },
                onTapTransfer: { _ in },
                onDeleteTransfer: { _ in },
                onEditTransfer: { _ in }
            )
        }
    }
}
