//
//  MonthlyFlowChartView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 12/06/2026.
//

import SwiftUI
import Charts

/// Grouped chart of the current year: two bars per month (income vs expense),
/// with the net (income − expense) overlaid as a line.
/// `data` already holds the 12 months of the year (see `ChartDataCalculator.monthlyFlows`),
/// so months without data simply render no bar.
struct MonthlyFlowChartView: View {

    let data: [MonthlyFlow]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Revenus & dépenses par mois")
                .font(.headline)

            Chart(data) { flow in
                // Two bars side by side per month: income then expense.
                BarMark(
                    x: .value("Mois", flow.month, unit: .month),
                    y: .value("Montant", flow.income)
                )
                .foregroundStyle(by: .value("Série", "Revenus"))
                .position(by: .value("Série", "Revenus"))

                BarMark(
                    x: .value("Mois", flow.month, unit: .month),
                    y: .value("Montant", flow.expense)
                )
                .foregroundStyle(by: .value("Série", "Dépenses"))
                .position(by: .value("Série", "Dépenses"))

                // Net line for completed months that have data only: the current month is
                // still partial, and empty months would otherwise plot a point at 0.
                if flow.month < Calendar.startOfCurrentMonth && flow.hasData {
                    LineMark(
                        x: .value("Mois", flow.month, unit: .month),
                        y: .value("Net", flow.net)
                    )
                    .foregroundStyle(by: .value("Série", "Net"))
                    .symbol(.circle)
                }
            }
            .chartForegroundStyleScale([
                "Revenus": Color.green,
                "Dépenses": Color.red,
                "Net": Color.accentColor
            ])
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisGridLine()
                    if let date = value.as(Date.self) {
                        AxisValueLabel { Text(Calendar.current.shortMonthLabel(for: date)) }
                    }
                }
            }
            .frame(height: 240)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        Section {
            MonthlyFlowChartView(
                data: ChartDataCalculator.monthlyFlows(PreviewData.chartTransactions)
            )
        }
    }
}
