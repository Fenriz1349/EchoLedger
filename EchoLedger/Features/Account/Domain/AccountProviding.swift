//
//  AccountProviding.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

/// Defines the contract for account persistence.
/// The Domain layer depends only on this protocol — it has no knowledge of SwiftData or Firebase.
/// Conforming types live in the Data layer.
protocol AccountProviding {

    /// Fetches all accounts belonging to a given institution.
    /// - Parameter institutionId: The identifier of the institution.
    /// - Returns: An array of accounts ordered by name.
    func fetchAll(for institutionId: UUID) async throws -> [Account]

    /// Fetches a single account by its identifier.
    /// - Parameter id: The unique identifier of the account.
    /// - Returns: The matching account.
    func fetch(by id: UUID) async throws -> Account

    /// Persists a new account.
    /// - Parameter account: The account to save.
    func save(_ account: Account) async throws

    /// Updates an existing account.
    /// - Parameter account: The account with updated values.
    func update(_ account: Account) async throws

    /// Deletes an account permanently.
    /// - Parameter id: The unique identifier of the account to delete.
    func delete(by id: UUID) async throws
}
