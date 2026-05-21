//
//  TransactionRowView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 21/05/2026.
//

import SwiftUI

/// A single list row displaying a transaction with a NavigationLink and swipe actions for edit and delete.
struct TransactionRowView: View {

    let transaction: Transaction
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        NavigationLink(value: transaction) {
        HStack {
            let name = transaction.category.icon
            Image(systemName: name)
                .frame(width: 32)

            VStack(alignment: .leading) {
                Text(transaction.label)
                    .font(.body)
                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(transaction.totalAmount.toEuro)
                .foregroundStyle(transaction.isExpense ? Color.primary : Color.green)
                .fontWeight(transaction.isExpense ? .regular : .semibold)
        }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                Task {
                    onDelete()
                }
            } label: {
                Label("Supprimer", systemImage: "trash")
            }
            Button {
                onEdit()
            } label: {
                Label("Modifier", systemImage: "pencil")
            }
        }

    }
}

#Preview {
    NavigationStack {
        List {
            TransactionRowView(
                transaction: PreviewData.transactionCourses,
                onEdit: {},
                onDelete: {}
            )
        }
    }
}
