//
//  ContentView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 18/11/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("EchoLedger")
            .task {
                do {
                    let dataSource = UserRemoteDataSource()
                    let uid = try await dataSource.signInAnonymously()
                    print("✅ User anonyme : \(uid)")
                } catch {
                    print("❌ Erreur : \(error)")
                }
            }
    }
}

#Preview {
    ContentView()
}
