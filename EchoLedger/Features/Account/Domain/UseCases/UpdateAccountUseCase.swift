//
//  UpdateAccountUseCase.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

struct UpdateAccountUseCase {
    let repository: AccountProviding

    func execute(account: Account,
                 newName: String,
                 newType: AccountType,
                 newInitialBalance: Double) throws {
        
        guard newName.isEmpty == false else { throw AccountError.emptyName }

        account.name = newName
        account.type = newType
        account.initialBalance = newInitialBalance

        try repository.updateAccount(account)
    }
}
