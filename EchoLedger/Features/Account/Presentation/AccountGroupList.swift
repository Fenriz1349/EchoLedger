//
//  AccountGroupList.swift
//  EchoLedger
//
//  Created by Julien Cotte on 21/05/2026.
//

import SwiftUI

/// The section header shows the institution name and the sum of its account balances.
/// Displays accounts grouped by institution, each row wrapped in a NavigationLink.
/// The institution name in the section header is tappable to open the edit form.
/// When `onArchive` is provided, the archive swipe action is shown.
/// When `onArchive` is nil (archived accounts), only edit is available.
struct AccountGroupList: View {

    let items: [(institution: Institution, accounts: [Account])]
    let balances: [UUID: Double]
    var percentages: [UUID: Double] = [:]
    let onEdit: (Account) -> Void
    let onArchive: ((Account) -> Void)?
    let onEditInstitution: (Institution) -> Void

    var body: some View {
        ForEach(items, id: \.institution.id) { item in
            let total = item.accounts.map { balances[$0.id] ?? 0 }.reduce(0, +)
            Section {
                ForEach(Array(item.accounts.enumerated()), id: \.element.id) { index, account in
                    NavigationLink(value: account) {
                        AccountRowView(
                            account: account,
                            balance: balances[account.id] ?? 0,
                            onEdit: { onEdit(account) },
                            onArchive: onArchive.map { archive in { archive(account) } }
                        )
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(
                        AccountRowBackground(
                            percentage: percentages[account.id] ?? 0,
                            color: (balances[account.id] ?? 0).balanceColor,
                            index: index
                        )
                    )
                }
            } header: {
                HStack {
                    Button {
                        onEditInstitution(item.institution)
                    } label: {
                        Text(item.institution.name)
                            .foregroundStyle(.primary)
                    }
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
