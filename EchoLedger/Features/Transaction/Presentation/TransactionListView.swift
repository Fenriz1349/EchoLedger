//
//  TransactionListView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI

struct TransactionListView: View {

    var body: some View {
        NavigationStack {
            Text("Transactions — liste complète des transactions")
                .navigationTitle("Transactions")
        }
    }
}

#Preview {
    TransactionListView()
        .environment(DIContainer(inMemory: true))
}

#Preview {
    TransactionListView()
}
