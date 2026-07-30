//
//  DeleteMode.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/07/2026.
//

import Foundation

/// The two ways a delete confirmation can resolve:
///  - keep the linked transactions (the default, via a RetireXRule)
///  - erase everything (via the destructive DeleteXRule).
enum DeleteMode {
    case keepHistory
    case everything
}
