//
//  AccountPickerView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 03/04/2026.
//

import SwiftUI

struct AccountPickerView: View {

    @Binding var selectedAccount: Account?
    let availableAccounts: [Account]

    var body: some View {
        Picker("Compte", selection: $selectedAccount) {
            ForEach(availableAccounts, id: \.id) { account in
                Text(account.name).tag(Optional(account))
            }
        }
    }
}

#Preview {
    Form {
        AccountPickerView(
            selectedAccount: .constant(PreviewData.accountCourant),
            availableAccounts: PreviewData.accounts
        )
    }
}
