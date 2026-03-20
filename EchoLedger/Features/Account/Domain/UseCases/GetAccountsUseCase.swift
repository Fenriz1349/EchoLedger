//
//  GetAccountsUseCase.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

struct GetAccountsUseCase {
    let repository: AccountProviding

    func execute() -> [Account] {
        repository.fetchAccounts()
    }
}
