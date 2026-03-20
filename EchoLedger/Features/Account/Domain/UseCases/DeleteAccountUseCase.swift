//
//  DeleteAccountUseCase.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

struct DeleteAccountUseCase {
    let repository: AccountProviding

    func execute(_ account: Account) throws {
        try repository.deleteAccount(account)
    }
}
