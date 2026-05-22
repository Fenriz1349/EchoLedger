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

    let transfer: Transfer
    let sourceName: String
    let destinationName: String
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
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
                        if transfer.label.isEmpty {
                            Text(transfer.date.formatted(date: .abbreviated, time: .omitted))
                        } else {
                            Text("\(transfer.label) · \(transfer.date.formatted(date: .abbreviated, time: .omitted))")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Text(transfer.amount.toEuro)
                    .foregroundStyle(Color.primary)
            }
        }
        .buttonStyle(.plain)
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
    let transfer = Transfer(source: PreviewData.transferExpense, destination: PreviewData.transferIncome)
    NavigationStack {
        List {
            TransferRowView(
                transfer: transfer,
                sourceName: PreviewData.accountCourant.name,
                destinationName: PreviewData.accountLivret.name,
                onTap: {},
                onDelete: {}
            )
        }
    }
}
