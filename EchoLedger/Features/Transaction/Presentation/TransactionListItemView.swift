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
    let onDelete: (Transaction) -> Void
    let onDeleteTransfer: (Transaction, Transaction) -> Void

    var body: some View {
        switch item {
        case .single(let transaction):
            TransactionRowView(
                transaction: transaction,
                onEdit: { onEdit(transaction) },
                onDelete: { onDelete(transaction) }
            )
        case .transfer(let expense, let income):
            let sourceName = expense.splits.first.flatMap { accountNames[$0.accountId] } ?? "Compte source"
            let destinationName = income.splits.first.flatMap { accountNames[$0.accountId] } ?? "Compte destination"
            TransferRowView(
                expense: expense,
                income: income,
                sourceName: sourceName,
                destinationName: destinationName,
                onDelete: { onDeleteTransfer(expense, income) }
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
                item: .transfer(expense: PreviewData.transferExpense, income: PreviewData.transferIncome),
                accountNames: accountNames,
                onEdit: { _ in },
                onDelete: { _ in },
                onDeleteTransfer: { _, _ in }
            )
            TransactionListItemView(
                item: .single(PreviewData.transactionCourses),
                accountNames: accountNames,
                onEdit: { _ in },
                onDelete: { _ in },
                onDeleteTransfer: { _, _ in }
            )
        }
    }
}
