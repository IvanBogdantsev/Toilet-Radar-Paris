//
//  TimeFormatterConfiguration.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 04.03.2023.
//

import Foundation

enum TimeRoundingIncrement: Double {
    case toNearestMinute = 60
    case toNearestHalfMinute = 30
    case none = 1
}
// MARK: todo enum with associated value
enum TimeMeasure: Double {
    case hour = 3600
    case halfHour = 1800
    case quarterHour = 900
    case tenMinutes = 600
    case fiveMinutes = 300
    case minute = 60
    case thirtySeconds = 30
    case tenSeconds = 10
    case none = 0
}

struct TimeFormatterOptions {
    let allowedUnits: NSCalendar.Unit
    let unitsStyle: DateComponentsFormatter.UnitsStyle
    let roundingIncrement: TimeRoundingIncrement
    let showsExactBelow: TimeMeasure
    let includesTimeRemainingPhrase: Bool
    let includesApproximationPhrase: Bool
    
    init(allowedUnits: NSCalendar.Unit = [.hour, .minute, .second],
         unitsStyle: DateComponentsFormatter.UnitsStyle = .short,
         roundingIncrement: TimeRoundingIncrement = .toNearestMinute,
         showsExactBelow: TimeMeasure = .minute,
         includesTimeRemainingPhrase: Bool = false,
         includesApproximationPhrase: Bool = false) {
        self.allowedUnits = allowedUnits
        self.unitsStyle = unitsStyle
        self.roundingIncrement = roundingIncrement
        self.showsExactBelow = showsExactBelow
        self.includesTimeRemainingPhrase = includesTimeRemainingPhrase
        self.includesApproximationPhrase = includesApproximationPhrase
    }
}
