//
//  AccountListView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI

struct AccountListView: View {

    var body: some View {
        NavigationStack {
            Text("Comptes — liste des comptes par établissement")
                .navigationTitle("Comptes")
        }
    }
}

#Preview {
    AccountListView()
        .environment(DIContainer(inMemory: true))
}

#Preview {
    AccountListView()
}
