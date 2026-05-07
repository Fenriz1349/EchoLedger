//
//  AccountPickerView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 03/04/2026.
//

import SwiftUI

/// A picker allowing the user to select one account from a list of available accounts.
struct AccountPickerView: View {

    @Binding var selectedAccountId: UUID
    let availableAccounts: [Account]

    var body: some View {
        Picker("Compte", selection: $selectedAccountId) {
            ForEach(availableAccounts, id: \.id) { account in
                Text(account.name).tag(account.id)
            }
        }
    }
}

#Preview {
    Form {
        AccountPickerView(
            selectedAccountId: .constant(PreviewData.accountCourant.id),
            availableAccounts: PreviewData.accounts
        )
    }
}
