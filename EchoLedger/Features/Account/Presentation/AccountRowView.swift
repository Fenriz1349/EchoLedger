//
//  AccountRowView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 09/04/2026.
//

import SwiftUI

/// A single account row: name + animated balance, over a full-cell `AccountRowBackground` that draws
/// the proportional share bar. The amount sits on a scrim so it stays readable over the bar.
struct AccountRowView: View {

    let account: Account
    let balance: Double
    let onEdit: () -> Void
    let onArchive: (() -> Void)?

    var body: some View {
        HStack {
            Image(systemName: account.category.icon)
            Text(account.name)
            Spacer()
            AnimatedAmountView(value: balance)
                .fontWeight(balance >= 0 ? .regular : .semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color(.secondarySystemGroupedBackground), in: Capsule())
        }
        .swipeActions(edge: .trailing) {
            if let onArchive {
                Button(role: .destructive) {
                    onArchive()
                } label: {
                    Label("Archiver", systemImage: "trash")
                }
            }
        }
        .swipeActions(edge: .trailing) {
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
    List {
        AccountRowView(account: PreviewData.accountCourant, balance: 1250.50, onEdit: {}, onArchive: {})
            .listRowBackground(AccountRowBackground(percentage: 0.6, color: .green))
    }
    .listStyle(.plain)
}
