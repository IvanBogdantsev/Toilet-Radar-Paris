//
//  DistanceFormatterOptions.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 06.03.2023.
//

import Foundation

enum DistanceRoundingIncrement: Double {
    case toEveryHundred = 100
    case toEveryFifty = 50
    case toEveryTen = 10
    case toEveryFive = 5
    case none = 1
}
// TODO: enum with associated value
enum DistanceMeasure: Double {
    case kilometer = 1000
    case halfKilometer = 500
    case quarterKilometer = 250
    case hundredMeters = 100
    case fiftyMeters = 50
    case tenMeters = 10
    case none = 0
}

struct DistanceFormatterOptions {
    let unitStyle: Formatter.UnitStyle
    let roundingAboveKm: DistanceRoundingIncrement
    let roundingBelowKm: DistanceRoundingIncrement
    let shouldShowExactBelow: DistanceMeasure
    
    init(unitsStyle: Formatter.UnitStyle = .medium,
         roundingAboveKm: DistanceRoundingIncrement = .toEveryHundred,
         roundingBelowKm: DistanceRoundingIncrement = .toEveryTen,
         shouldShowExactBelow: DistanceMeasure = .fiftyMeters) {
        self.unitStyle = unitsStyle
        self.roundingAboveKm = roundingAboveKm
        self.roundingBelowKm = roundingBelowKm
        self.shouldShowExactBelow = shouldShowExactBelow
    }
}
