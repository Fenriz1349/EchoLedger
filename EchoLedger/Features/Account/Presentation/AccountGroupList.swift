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
struct AccountGroupList: View {
    
    let items: [(institution: Institution, accounts: [Account])]
    let onEdit: (Account) -> Void
    let onArchive: ((Account) -> Void)?
    
    var body: some View {
        ForEach(items, id: \.institution.id) { item in
            Section(item.institution.name) {
                ForEach(item.accounts) { account in
                    NavigationLink(value: account) {
                        AccountRowView(
                            account: account,
                            onEdit: { onEdit(account) },
                            onArchive: onArchive.map { fn in { fn(account) } }
                        )
                    }
                }
            }
        }
    }
}
