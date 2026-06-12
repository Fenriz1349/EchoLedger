//
//  Transaction+Effective.swift
//  EchoLedger
//
//  Created by Julien Cotte on 12/06/2026.
//

import Foundation

extension Transaction {

    /// A transaction is "effective" once its day has arrived.
    ///
    /// Future-dated transactions (e.g. scheduled recurrences) are excluded from
    /// the main list, balances, charts and aggregates until their date passes.
    /// Comparison is done at day granularity, so a transaction dated today is
    /// always effective regardless of its time.
    /// - Parameter reference: The date to compare against. Defaults to now.
    /// - Returns: `true` if the transaction's day is today or in the past.
    func isEffective(asOf reference: Date = Date()) -> Bool {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date) <= calendar.startOfDay(for: reference)
    }
}
