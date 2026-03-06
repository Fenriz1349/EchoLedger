//
//  TransactionSplit.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

import SwiftData
import Foundation

@Model
class TransactionSplit {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var date: Date
    var comment: String
    
    var account: [Account]?

    init(amount: Double, date: Date, comment: String, account: [Account]?) {
        self.id = UUID()
        self.amount = amount
        self.date = date
        self.comment = comment
        self.account = account
    }
}
