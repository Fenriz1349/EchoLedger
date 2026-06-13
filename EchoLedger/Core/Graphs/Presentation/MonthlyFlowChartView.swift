//
//  MonthlyFlowChartView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 12/06/2026.
//

import SwiftUI
import Charts

/// Grouped bar chart of the current year: two bars per month (income vs expense).
/// `data` holds the 12 months of the year (see `ChartDataCalculator.monthlyFlows`);
/// months without data render no bar.
struct MonthlyFlowChartView: View {

    let data: [MonthlyFlow]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Revenus & dépenses par mois")
                .font(.headline)

            Chart(data) { flow in
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
            }
            .chartForegroundStyleScale([
                "Revenus": Color.green,
                "Dépenses": Color.red
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
