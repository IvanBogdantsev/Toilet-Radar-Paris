//
//  TimeFormatter.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 04.03.2023.
//

import Foundation

final class TimeFormatter: TimeFormatterProtocol {
    
    private let formatter: DateComponentsFormatter
    
    private var options: TimeFormatterOptions {
        didSet {
            formatter.allowedUnits = options.allowedUnits
            formatter.unitsStyle = options.unitsStyle
            formatter.includesTimeRemainingPhrase = options.includesTimeRemainingPhrase
            formatter.includesApproximationPhrase = options.includesApproximationPhrase
        }
    }
    
    private var increment: Double { options.roundingIncrement.rawValue }
    
    private var roundingThreshold: Double { options.showsExactBelow.rawValue }
    
    var timeFormatterOptions: TimeFormatterOptions {
        get { options }
        set { options = newValue }
    }
    
    init(timeFormatterOptions: TimeFormatterOptions = TimeFormatterOptions()) {
        formatter = DateComponentsFormatter()
        formatter.allowedUnits = timeFormatterOptions.allowedUnits
        formatter.unitsStyle = timeFormatterOptions.unitsStyle
        formatter.includesTimeRemainingPhrase = timeFormatterOptions.includesTimeRemainingPhrase
        formatter.includesApproximationPhrase = timeFormatterOptions.includesApproximationPhrase
        options = timeFormatterOptions
    }
    
    func string(from timeInterval: TimeInterval) -> String? {
        let seconds = timeInterval < roundingThreshold ? timeInterval :
        timeInterval.roundedToClosestDivider(of: increment)
        return formatter.string(from: seconds)
    }
    
}
