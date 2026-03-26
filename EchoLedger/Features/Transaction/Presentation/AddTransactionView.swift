//
//  AddTransactionView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI

struct AddTransactionView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("Ajouter une transaction")
                .navigationTitle("Nouvelle transaction")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annuler") { dismiss() }
                    }
                }
        }
    }
}

#Preview {
    AddTransactionView()
        .environment(DIContainer(inMemory: true))
}
