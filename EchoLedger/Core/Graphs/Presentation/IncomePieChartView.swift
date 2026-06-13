//
//  IncomePieChartView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 21/05/2026.
//

import SwiftUI
import Charts

/// Pie chart showing income distribution by category, as a share of the total.
/// Slices ≥ 5% are labelled directly on the chart; the legend below lists every category.
struct IncomePieChartView: View {

    let data: [CategorySlice]

    private var total: Double {
        data.reduce(0) { $0 + $1.total }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Revenus par catégorie")
                .font(.headline)

            Chart(data, id: \.category) { item in
                SectorMark(
                    angle: .value("Montant", item.total),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(item.category.color)
                .cornerRadius(4)
                .annotation(position: .overlay) {
                    if item.percentage >= 5 {
                        VStack(spacing: 1) {
                            Text(item.category.name)
                            Text("\(Int(item.percentage.rounded())) %")
                        }
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    }
                }
            }
            .frame(height: 220)

            // Full legend — every category with its share.
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

            Divider()

            HStack {
                Text("Total")
                    .font(.caption.weight(.medium))
                Spacer()
                Text(total.toEuro)
                    .font(.caption.weight(.medium))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        Section {
            IncomePieChartView(
                data: ChartDataCalculator.categoryBreakdown(PreviewData.chartTransactions, isExpense: false)
            )
        }
    }
}
