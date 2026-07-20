//
//  AccountRecencySorter.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/07/2026.
//

import Foundation

/// Pure sorting logic ranking accounts by how recently each was used.
/// Never-used accounts sink to the bottom, sorted alphabetically among themselves.
enum AccountRecencySorter {

    /// - Parameters:
    ///   - items: The accounts to sort.
    ///   - transactions: Transactions used to derive each account's last-used date.
    /// - Returns: `items` ordered by most recent split date first.
    static func sort(_ items: [AccountDisplayItem], using transactions: [Transaction]) -> [AccountDisplayItem] {
        var lastUsedDates: [UUID: Date] = [:]
        for transaction in transactions {
            for split in transaction.splits {
                if let existing = lastUsedDates[split.accountId], existing > transaction.date { continue }
                lastUsedDates[split.accountId] = transaction.date
            }
        }

        return items.sorted { lhs, rhs in
            switch (lastUsedDates[lhs.account.id], lastUsedDates[rhs.account.id]) {
            case let (lhsDate?, rhsDate?): return lhsDate > rhsDate
            case (.some, nil): return true
            case (nil, .some): return false
            case (nil, nil): return lhs.account.name < rhs.account.name
            }
        }
    }
}
