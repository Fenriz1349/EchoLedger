//
//  LoadingView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/04/2026.
//

import SwiftUI

/// Full-screen loading view shown while the app resolves the existing session at launch.
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 24) {
            EchoLedgerLoader()
                .frame(width: 120, height: 120)

            AppNameView()
        }
        .echoBackground()
    }
}

#Preview {
    LoadingView()
}
