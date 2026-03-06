//
//  Institution.swift
//  CatLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation
import SwiftData

@Model
class Institution {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: InstitutionType

    @Relationship(deleteRule: .cascade)
    var accounts: [Account] = []

    init(name: String, type: InstitutionType) {
        self.id = UUID()
        self.name = name
        self.type = type
    }
}

