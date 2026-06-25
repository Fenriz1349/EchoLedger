//
//  SplitFormContent.swift
//  EchoLedger
//
//  Created by Julien Cotte on 03/04/2026.
//

import SwiftUI

/// A single editable row representing one split of a transaction across an account.
struct SplitFormContent: View {

    @Binding var split: TransactionSplit
    let availableAccounts: [AccountDisplayItem]
    let onDelete: (() -> Void)?

    @State private var amountText = ""

    var body: some View {
        HStack {
            TextField("0,00€", text: $amountText)
                .keyboardType(.decimalPad)
                .onAppear {
                    amountText = split.amount == 0 ? "": String(split.amount)
                }
                .onChange(of: amountText) { _, newValue in
                    let filtered = newValue.numericOnly
                    if filtered != newValue {
                        amountText = filtered
                    }
                    split.amount = filtered.toDouble
                }
            Picker("", selection: $split.accountId) {
                ForEach(availableAccounts) { item in
                    Text(item.displayLabel)
                        .tag(item.account.id)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
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
        SplitFormContent(
            split: .constant(split),
            availableAccounts: [AccountDisplayItem(account: PreviewData.accountCourant,
                                                   institutionName: PreviewData.institutionBNP.name)],
            onDelete: {}
        )
    }
}
