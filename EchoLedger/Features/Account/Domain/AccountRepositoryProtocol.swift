//
//  AccountRepositoryProtocol.swift
//  CatLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

protocol AccountRepositoryProtocol {
    func createAccount(name: String,
                       type: AccountType,
                       initialBalance: Double,
                       institution: Institution) throws -> Account

    func fetchAccounts() -> [Account]

    func updateAccount(_ account: Account) throws

    func deleteAccount(_ account: Account) throws
}
