//
//  Calendar+Extension.swift
//  EchoLedger
//
//  Created by Julien Cotte on 12/06/2026.
//

import Foundation

extension Calendar {

    /// First day of the current month. Months strictly before it are considered completed.
    static var startOfCurrentMonth: Date {
        current.startOfMonth(for: Date())
    }

    /// First day of the month containing `date`.
    /// `self.date(from:)` is required: the `date` parameter would otherwise shadow the method.
    func startOfMonth(for date: Date) -> Date {
        self.date(from: dateComponents([.year, .month], from: date)) ?? startOfDay(for: date)
    }

    /// The first day of each of the 12 months of `year`, from January to December.
    func months(ofYear year: Int) -> [Date] {
        (1...12).compactMap {
            date(from: DateComponents(year: year, month: $0, day: 1))
        }
    }

    /// Compact French month label for the month containing `date` — 3 letters,
    /// except "Juin"/"Juil" (4) to disambiguate them. Used for tight chart axes.
    func shortMonthLabel(for date: Date) -> String {
        let symbols = ["Jan", "Fév", "Mar", "Avr", "Mai", "Juin",
                       "Juil", "Aoû", "Sep", "Oct", "Nov", "Déc"]
        let index = component(.month, from: date) - 1
        return symbols.indices.contains(index) ? symbols[index] : ""
    }
}
