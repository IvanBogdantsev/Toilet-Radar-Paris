//
//  TimeFormatterConfiguration.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 04.03.2023.
//

import Foundation

enum RoundingStrategy: Double {
    case halfUpToWholeMinute = 60
    case quarterUpToHalfMinute = 30
    case none = 1
}

struct TimeFormatterOptions {
    let allowedUnits: NSCalendar.Unit
    let unitsStyle: DateComponentsFormatter.UnitsStyle
    let includesTimeRemainingPhrase: Bool
    let includesApproximationPhrase: Bool
    let exactSecsBelowMinute: Bool
    let roundingStrategy: RoundingStrategy
}
