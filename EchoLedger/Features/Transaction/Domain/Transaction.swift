//
//  Transaction.swift
//  CatLedger
//
//  Created by Julien Cotte on 18/11/2025.
//

import SwiftData
import Foundation

@Model
class Transaction {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var date: Date
    var comment: String
    
    var account: Account?

    init(amount: Double, date: Date, comment: String, account: Account?) {
        self.id = UUID()
        self.amount = amount
        self.date = date
        self.comment = comment
        self.account = account
    }
}
