//
//  MonthlyPieCarouselView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 13/06/2026.
//

import SwiftUI

/// Carousel displaying expense and income pie charts for each month with data.
/// Navigation state and logic are owned by the caller's ViewModel.
/// Supports horizontal swipe and chevron buttons to move between months.
/// - Parameters:
///   - months: Chronologically ordered list of months with data.
///   - currentIndex: Index of the currently displayed month.
///   - onPrevious: Called when the user navigates to the previous month.
///   - onNext: Called when the user navigates to the next month.
///   - onSwipe: Called with the drag translation so the ViewModel can interpret direction.
struct MonthlyPieCarouselView: View {

    let months: [MonthlyPieData]
    let currentIndex: Int
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onSwipe: (CGSize) -> Void

    var body: some View {
        VStack(spacing: 16) {
            PieCarouselNavigation(
                months: months,
                currentIndex: currentIndex,
                onPrevious: onPrevious,
                onNext: onNext
            )

            let current = months[currentIndex]

            if !current.expenses.isEmpty {
                ExpensePieChartView(data: current.expenses)
            }

            if !current.income.isEmpty {
                IncomePieChartView(data: current.income)
            }

            if current.expenses.isEmpty && current.income.isEmpty {
                Text("Aucune donnée pour ce mois")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            }

            PieCarouselPageIndicator(count: months.count, currentIndex: currentIndex)
        }
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onEnded { onSwipe($0.translation) }
        )
    }
}

#Preview {
    let months = ChartDataCalculator.monthlyPieBreakdown(PreviewData.chartTransactions)
    return List {
        Section {
            MonthlyPieCarouselView(
                months: months,
                currentIndex: max(months.count - 1, 0),
                onPrevious: {},
                onNext: {},
                onSwipe: { _ in }
            )
        }
    }
}
