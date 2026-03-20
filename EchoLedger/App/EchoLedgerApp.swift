//
//  EchoLedgerApp.swift
//  EchoLedger
//
//  Created by Julien Cotte on 27/02/2026.
//

import SwiftUI
import FirebaseCore

@main
struct EchoLedgerApp: App {

    init() {
        FirebaseApp.configure()
        print("Firebase configured: \(FirebaseApp.app() != nil)")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
