//
//  PieCarouselNavigation.swift
//  EchoLedger
//
//  Created by Julien Cotte on 13/06/2026.
//

import SwiftUI

/// Navigation header for the monthly pie carousel.
/// Displays the current month label with a prev/next chevron on each side.
/// Chevrons are disabled and dimmed at the bounds of the available months.
/// - Parameters:
///   - months: Full list of available months.
///   - currentIndex: Index of the currently displayed month.
///   - onPrevious: Called when the user taps the previous chevron.
///   - onNext: Called when the user taps the next chevron.
struct PieCarouselNavigation: View {

    let months: [MonthlyPieData]
    let currentIndex: Int
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(currentIndex > 0 ? Color.secondary : Color.secondary.opacity(0.3))
            }
            .disabled(currentIndex == 0)

            Spacer()

            Text(Calendar.current.monthYearLabel(for: months[currentIndex].month))
                .font(.headline)
                .animation(.easeInOut(duration: 0.2), value: currentIndex)

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(currentIndex < months.count - 1 ? Color.secondary : Color.secondary.opacity(0.3))
            }
            .disabled(currentIndex == months.count - 1)
        }
    }
}

#Preview {
    let months = ChartDataCalculator.monthlyPieBreakdown(PreviewData.chartTransactions)
    return PieCarouselNavigation(
        months: months,
        currentIndex: max(months.count - 1, 0),
        onPrevious: {},
        onNext: {}
    )
    .padding()
}
