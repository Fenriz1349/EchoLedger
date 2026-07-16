//
//  TransactionRowView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 21/05/2026.
//

import SwiftUI

/// A single tappable transaction row with trailing swipe actions for edit and delete.
struct TransactionRowView: View {

    let transaction: Transaction
    let onTap: () -> Void
    let onEdit: () -> Void
    /// Nil when the transaction may not be deleted (an initial balance lives with its account).
    let onDelete: (() -> Void)?

    var body: some View {
        Button(action: onTap) {
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

                AnimatedAmountView(value: transaction.totalAmount, color: transaction.color)
                    .fontWeight(transaction.isExpense ? .regular : .semibold)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            if let onDelete {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Supprimer", systemImage: "trash")
                }
            }
            Button {
                onEdit()
            } label: {
                Label("Modifier", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            TransactionRowView(
                transaction: PreviewData.transactionCourses,
                onTap: {},
                onEdit: {},
                onDelete: {}
            )
        }
    }
}
