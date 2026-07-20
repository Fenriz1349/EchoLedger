//
//  AppLogoView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 19/06/2026.
//

import SwiftUI

/// AppLogoe to uniformaze style
struct AppLogoView: View {

    var body: some View {
        Image("Logo")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
    }
}

#Preview {
    AppLogoView()
}
