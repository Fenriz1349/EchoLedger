//
//  TransferRowView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 22/05/2026.
//

import SwiftUI

/// A single list row displaying an internal transfer between two accounts.
/// Swipe to delete removes both the expense and income legs simultaneously.
struct TransferRowView: View {

    let expense: Transaction
    let income: Transaction
    let sourceName: String
    let destinationName: String
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(sourceName)
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(destinationName)
                }
                .font(.body)

                Group {
                    if expense.label.isEmpty {
                        Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    } else {
                        Text("\(expense.label) · \(expense.date.formatted(date: .abbreviated, time: .omitted))")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(expense.totalAmount.toEuro)
                .foregroundStyle(Color.primary)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Supprimer", systemImage: "trash")
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            TransferRowView(
                expense: PreviewData.transferExpense,
                income: PreviewData.transferIncome,
                sourceName: PreviewData.accountCourant.name,
                destinationName: PreviewData.accountLivret.name,
                onDelete: {}
            )
        }
    }
}
