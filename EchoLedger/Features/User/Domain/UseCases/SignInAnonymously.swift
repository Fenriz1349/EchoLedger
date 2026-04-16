//
//  SignInAnonymously.swift
//  EchoLedger
//
//  Created by Julien Cotte on 16/04/2026.
//

import Foundation

/// Handles anonymous Firebase Auth sign-in.
/// Ensures a remote user session exists before any Firestore operations.
final class SignInAnonymously {

    private let remoteSource: UserRemoteSource

    /// - Parameter remoteSource: The remote data source handling Firebase Auth.
    init(remoteSource: UserRemoteSource) {
        self.remoteSource = remoteSource
    }

    /// Signs in anonymously with Firebase Auth if no session currently exists.
    /// - Returns: A stable UUID derived from the Firebase Auth uid.
    /// - Throws: A Firebase Auth error if sign-in fails.
    func execute() async throws -> UUID {
        let uid = try await remoteSource.signInAnonymously()
        return uid.toUUID
    }
}
