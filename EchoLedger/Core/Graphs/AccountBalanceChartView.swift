//
//  AccountBalanceChartView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 21/05/2026.
//

import SwiftUI
import Charts

/// Horizontal bar chart showing the balance per account.
/// Positive balances appear in green, negative in red.
struct AccountBalanceChartView: View {

    let items: [AccountBalance]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Répartition par compte")
                .font(.headline)

            Chart(items, id: \.account.id) { item in
                BarMark(
                    x: .value("Solde", item.balance),
                    y: .value("Compte", item.account.name)
                )
                .foregroundStyle(item.balance >= 0 ? Color.green : Color.red)
                .cornerRadius(4)
                .annotation(position: item.balance >= 0 ? .trailing : .leading) {
                    Text(item.balance.toEuro)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .chartXAxis(.hidden)
            .frame(height: CGFloat(items.count) * 44)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        Section {
            AccountBalanceChartView(items: [
                AccountBalance(account: PreviewData.accountCourant, balance: 1250.50),
                AccountBalance(account: PreviewData.accountLivret, balance: 3200.00),
                AccountBalance(account: PreviewData.accountSwile, balance: -85.20)
            ])
        }
    }
}
