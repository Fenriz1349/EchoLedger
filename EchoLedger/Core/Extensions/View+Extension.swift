//
//  View+Extension.swift
//  EchoLedger
//
//  Created by Julien Cotte on 25/06/2026.
//

import UIKit

extension UIView {

    /// Resigns the first responder to dismiss the numeric keyboard.
    static func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
        )
    }
}
