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
    let onDelete: () -> Void

    var body: some View {
        SwipeRow(
            actions: [
                .init(label: "Modifier", systemImage: "pencil", tint: .blue, action: onEdit),
                .init(label: "Supprimer", systemImage: "trash", tint: .red, action: onDelete)
            ],
            onTap: onTap
        ) {
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
