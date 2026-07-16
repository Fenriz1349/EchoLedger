//
//  TransactionListItemView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 22/05/2026.
//

import SwiftUI

/// Dispatches to the appropriate row view based on the `TransactionListItem` type.
/// All transaction lists use this view exclusively — never call `TransactionRowView` or `TransferRowView` directly.
struct TransactionListItemView: View {

    let item: TransactionListItem
    let accountNames: [UUID: String]
    let onEdit: (Transaction) -> Void
    /// Nil when the item may not be deleted (an initial balance lives with its account).
    let onDelete: ((Transaction) -> Void)?
    let onTap: (Transaction) -> Void
    let onTapTransfer: (Transfer) -> Void
    let onDeleteTransfer: (Transfer) -> Void
    let onEditTransfer: (Transfer) -> Void

    var body: some View {
        switch item {
        case .single(let transaction):
            TransactionRowView(
                transaction: transaction,
                onTap: { onTap(transaction) },
                onEdit: { onEdit(transaction) },
                onDelete: onDelete.map { delete in { delete(transaction) } }
            )
        case .transfer(let transfer):
            TransferRowView(
                transfer: transfer,
                sourceName: transfer.sourceName(from: accountNames),
                destinationName: transfer.destinationName(from: accountNames),
                onTap: { onTapTransfer(transfer) },
                onDelete: { onDeleteTransfer(transfer) },
                onEdit: { onEditTransfer(transfer) }
            )
        }
    }
}

#Preview {
    let accountNames: [UUID: String] = [
        PreviewData.accountCourant.id: PreviewData.accountCourant.name,
        PreviewData.accountLivret.id: PreviewData.accountLivret.name
    ]
    NavigationStack {
        List {
            TransactionListItemView(
                item: .transfer(Transfer(source: PreviewData.transferExpense, destination: PreviewData.transferIncome)),
                accountNames: accountNames,
                onEdit: { _ in },
                onDelete: { _ in },
                onTap: { _ in },
                onTapTransfer: { _ in },
                onDeleteTransfer: { _ in },
                onEditTransfer: { _ in }
            )
            TransactionListItemView(
                item: .single(PreviewData.transactionCourses),
                accountNames: accountNames,
                onEdit: { _ in },
                onDelete: { _ in },
                onTap: { _ in },
                onTapTransfer: { _ in },
                onDeleteTransfer: { _ in },
                onEditTransfer: { _ in }
            )
        }
    }
}
