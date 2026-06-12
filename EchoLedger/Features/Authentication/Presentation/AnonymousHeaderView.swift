//
//  AnonymousHeaderView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 12/06/2026.
//

import SwiftUI

struct AnonymousHeaderView: View {

    let dayInDemo: Int?

    var body: some View {
        VStack(spacing: 6) {
            Text("Mode démo")
                .font(.headline)
            if let days = dayInDemo {
                Text("Il vous reste \(days) jour\(days > 1 ? "s" : "").")
                    .font(.subheadline.bold())
                    .foregroundColor(.orange)
            }
            Text("En mode démo, certaines fonctionnalités sont limitées. "
                 + "Créez un compte pour tout débloquer et retrouver vos données partout.")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    AnonymousHeaderView(dayInDemo: 7)
}
