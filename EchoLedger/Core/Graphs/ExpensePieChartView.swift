//
//  ExpensePieChartView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 21/05/2026.
//

import SwiftUI
import Charts

/// Pie chart showing expense distribution by category.
/// Receives pre-computed data sorted by total descending.
struct ExpensePieChartView: View {

    let data: [(category: TransactionCategory, total: Double)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dépenses par catégorie")
                .font(.headline)

            Chart(data, id: \.category) { item in
                SectorMark(
                    angle: .value("Montant", item.total),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(item.category.color)
                .cornerRadius(4)
            }
            .frame(height: 220)

            // Legend
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                ForEach(data, id: \.category) { item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(item.category.color)
                            .frame(width: 10, height: 10)
                        Text(item.category.name)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Text(item.total.toEuro)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
