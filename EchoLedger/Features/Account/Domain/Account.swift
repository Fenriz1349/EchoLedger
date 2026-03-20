//
//  Account.swift
//  EchoLedger
//
//  Created by Julien Cotte on 18/11/2025.
//

import SwiftData
import Foundation

@Model
class Account {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: AccountType
    var initialBalance: Double
    var createdAt: Date

    @Relationship
    var institution: Institution

    @Relationship(deleteRule: .cascade)
    var transactions: [Transaction] = []

    init(name: String,
         initialBalance: Double,
         institution: Institution) {
        self.id = UUID()
        self.name = name
        self.type = .unknown
        self.initialBalance = initialBalance
        self.createdAt = Date()
        self.institution = institution
    }
}
