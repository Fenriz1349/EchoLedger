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
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()

            VStack(spacing: 24) {
                EchoLedgerLoader()
                    .frame(width: 120, height: 120)

                AppNameView()
            }
        }
    }
}

#Preview {
    LoadingView()
}
