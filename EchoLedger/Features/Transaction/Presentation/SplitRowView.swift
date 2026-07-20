//
//  SplitRowView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import SwiftUI

/// Displays one split of a transaction: account name on the left (with institution in caption below),
/// and the split amount aligned to the right.
struct SplitRowView: View {

    let amount: Double
    let accountName: String?
    let institutionName: String?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(accountName ?? "—")
                if let institutionName {
                    Text(institutionName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
                AnimatedAmountView(value: amount, color: .secondary)
        }
    }
}

#Preview {
    List {
        Section("Répartition") {
            SplitRowView(
                amount: 45.00,
                accountName: "Compte courant",
                institutionName: "BNP Paribas"
            )
            SplitRowView(
                amount: 20.00,
                accountName: "Livret A",
                institutionName: nil
            )
        }
    }
}
