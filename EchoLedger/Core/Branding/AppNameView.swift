//
//  AppNameView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 19/06/2026.
//

import SwiftUI

/// AppName to uniformaze style
struct AppNameView: View {

    var body: some View {
        Text("EchoLedger")
            .font(.largeTitle.bold())
            .foregroundStyle(.accent)
    }
}

#Preview {
    AppNameView()
}
