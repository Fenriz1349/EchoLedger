//
//  AccountRowView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 09/04/2026.
//

import SwiftUI

/// A single list row displaying an account with swipe actions for edit and archive.
struct AccountRowView: View {

    let account: Account
    let onEdit: () -> Void
    let onArchive: (() -> Void)?

    var body: some View {
        HStack {
            Image(systemName: account.category.icon)
            Text(account.name)
            Spacer()
            Text(account.category.name)
                .foregroundStyle(.secondary)
                .font(.caption)
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
    AccountRowView(
        account: PreviewData.accountCourant,
        onEdit: {},
        onArchive: {}
    )
}
