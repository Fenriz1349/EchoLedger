//
//  InstitutionProviding.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/11/2025.
//

import Foundation

/// Defines the contract for institution persistence.
/// The Domain layer depends only on this protocol — it has no knowledge of SwiftData or Firebase.
/// Conforming types live in the Data layer.
protocol InstitutionProviding {

    /// Fetches all institutions belonging to a given user.
    /// - Parameter userId: The identifier of the user.
    /// - Returns: An array of institutions ordered by name.
    func fetchAll(for userId: UUID) async throws -> [Institution]

    /// Fetches a single institution by its identifier.
    /// - Parameter id: The unique identifier of the institution.
    /// - Returns: The matching institution.
    func fetch(by id: UUID) async throws -> Institution

    /// Persists a new institution.
    /// - Parameter institution: The institution to save.
    func save(_ institution: Institution) async throws

    /// Updates an existing institution.
    /// - Parameter institution: The institution with updated values.
    func update(_ institution: Institution) async throws

    /// Archives an institution by marking it as inactive.
    /// - Parameter id: The unique identifier of the institution to archive.
    func archive(by id: UUID) async throws

    /// Restores an archived institution to active status.
    /// - Parameter id: The unique identifier of the institution to unarchive.
    func unarchive(by id: UUID) async throws

    /// Deletes an institution and all its associated accounts.
    /// - Parameter id: The unique identifier of the institution to delete.
    func delete(by id: UUID) async throws
}
