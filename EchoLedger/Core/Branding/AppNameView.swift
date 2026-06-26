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
            .font(.system(.largeTitle, design: .rounded).weight(.heavy))
            .foregroundStyle(
                LinearGradient(colors: [Color.echoAccentHard, Color.echoAccentSoft],
                               startPoint: .leading, endPoint: .trailing)
            )
    }
}

#Preview {
    AppNameView()
}
