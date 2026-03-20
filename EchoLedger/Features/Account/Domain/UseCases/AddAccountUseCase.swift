//
//  AddAccountUseCase.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

struct AddAccountUseCase {
    let repository: AccountRepositoryProtocol

    func execute(name: String,
                 type: AccountType,
                 initialBalance: Double) throws -> Account {
        throw AccountError.unknown
    }
}
