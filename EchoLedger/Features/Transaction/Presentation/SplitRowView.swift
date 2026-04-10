//
//  SplitRowView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 03/04/2026.
//

import SwiftUI

/// A single editable row representing one split of a transaction across an account.
struct SplitRowView: View {

    let index: Int
    @Binding var split: TransactionSplit
    let availableAccounts: [Account]
    let onDelete: () -> Void

    var body: some View {
        HStack {
            TextField("Montant", value: $split.amount, format: .number)
                .keyboardType(.decimalPad)
                .frame(width: 80)
            Picker("", selection: $split.accountId) {
                ForEach(availableAccounts, id: \.id) { account in
                    Text(account.name).tag(account.id)
                }
            }
        }
        .swipeActions {
            Button(role: .destructive) { onDelete() } label: {
                Label("Supprimer", systemImage: "trash")
            }
        }
    }
}

#Preview {
    var split = TransactionSplit(accountId: PreviewData.accountCourant.id, amount: 30)
    return List {
        SplitRowView(
            index: 0,
            split: .constant(split),
            availableAccounts: PreviewData.accounts,
            onDelete: {}
        )
    }
}
