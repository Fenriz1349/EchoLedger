//
//  SplitFormView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 03/04/2026.
//

import SwiftUI

/// A single editable row representing one split of a transaction across an account.
struct SplitFormView: View {

    @Binding var split: TransactionSplit
    let availableAccounts: [Account]
    let institutionNames: [UUID: String]
    let onDelete: (() -> Void)?

    var body: some View {
        HStack {
            TextField("0,00", value: $split.amount, format: .number)
                .keyboardType(.decimalPad)
                .frame(width: 80)

            Picker("", selection: $split.accountId) {
                ForEach(availableAccounts, id: \.id) { account in
                    if let institutionName = institutionNames[account.id] {
                        Text("\(account.name) • \(institutionName)")
                            .tag(account.id)
                    } else {
                        Text(account.name).tag(account.id)
                    }
                }
            }
        }
        .swipeActions {
            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Label("Supprimer", systemImage: "trash")
                }
            }
        }
    }
}

#Preview {
    let split = TransactionSplit(accountId: PreviewData.accountCourant.id, amount: 30)
    return List {
        SplitFormView(
            split: .constant(split),
            availableAccounts: PreviewData.accounts,
            institutionNames: [PreviewData.accountCourant.id: PreviewData.institutionBNP.name],
            onDelete: {}
        )
    }
}
