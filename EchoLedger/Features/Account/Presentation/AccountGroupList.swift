//
//  AccountGroupList.swift
//  EchoLedger
//
//  Created by Julien Cotte on 21/05/2026.
//

import SwiftUI

/// Displays accounts grouped by institution, each row wrapped in a NavigationLink.
/// When `onArchive` is provided, the archive swipe action is shown.
/// When `onArchive` is nil (archived accounts), only edit is available.
/// The section header shows the institution name and the sum of its account balances.
struct AccountGroupList: View {

    let items: [(institution: Institution, accounts: [Account])]
    let balances: [UUID: Double]
    let onEdit: (Account) -> Void
    let onArchive: ((Account) -> Void)?

    var body: some View {
        ForEach(items, id: \.institution.id) { item in
            let total = item.accounts.map { balances[$0.id] ?? 0 }.reduce(0, +)
            Section {
                ForEach(item.accounts) { account in
                    NavigationLink(value: account) {
                        AccountRowView(
                            account: account,
                            balance: balances[account.id] ?? 0,
                            onEdit: { onEdit(account) },
                            onArchive: onArchive.map { archive in { archive(account) } }
                        )
                    }
                }
            } header: {
                HStack {
                    Text(item.institution.name)
                    if item.accounts.count > 1 {
                        Spacer()
                        Text(total.toEuro)
                            .foregroundStyle(total >= 0 ? Color.green : Color.red)
                    }
                }
            }
        }
    }
}
