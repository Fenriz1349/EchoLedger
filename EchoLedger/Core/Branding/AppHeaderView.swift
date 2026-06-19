//
//  AppHeaderView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 19/06/2026.
//

import SwiftUI

/// AppLogo and AppName to uniformaze all headers
struct AppHeaderView: View {
    
    var body: some View {
        VStack(spacing: 8) {
            AppLogoView()
            AppNameView()
        }
    }
}

#Preview {
    AppHeaderView()
}
