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
    let availableAccounts: [AccountDisplayItem]
    let onDelete: (() -> Void)?

    var body: some View {
        HStack {
            TextField("0,00", value: $split.amount, format: .number)
                .keyboardType(.decimalPad)
                .frame(width: 80)

            Picker("", selection: $split.accountId) {
                ForEach(availableAccounts) { item in
                    Text(item.displayLabel).tag(item.account.id)
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
            availableAccounts: [AccountDisplayItem(account: PreviewData.accountCourant,
                                                   institutionName: PreviewData.institutionBNP.name)],
            onDelete: {}
        )
    }
}
