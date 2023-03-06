//
//  TimeFormatter.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 04.03.2023.
//

import Foundation

final class TimeFormatter {
    
    private let formatter: DateComponentsFormatter
    
    private var privateTimeFormatterOptions: TimeFormatterOptions {
        didSet {
            formatter.allowedUnits = privateTimeFormatterOptions.allowedUnits
            formatter.unitsStyle = privateTimeFormatterOptions.unitsStyle
            formatter.includesTimeRemainingPhrase = privateTimeFormatterOptions.includesTimeRemainingPhrase
            formatter.includesApproximationPhrase = privateTimeFormatterOptions.includesApproximationPhrase
        }
    }
    
    private var divider: Double { privateTimeFormatterOptions.roundingStrategy.rawValue }
    
    private var shouldShowExact: Bool { privateTimeFormatterOptions.exactSecsBelowMinute }
    
    var timeFormatterOptions : TimeFormatterOptions {
        get { privateTimeFormatterOptions }
        set { privateTimeFormatterOptions = newValue }
    }
    
    init(timeFormatterOptions: TimeFormatterOptions = TimeFormatterOptions(allowedUnits: [.hour, .minute, .second],
                                                                           unitsStyle: .short,
                                                                           includesTimeRemainingPhrase: false,
                                                                           includesApproximationPhrase: false,
                                                                           exactSecsBelowMinute: true,
                                                                           roundingStrategy: .halfUpToWholeMinute))
    {
        formatter = DateComponentsFormatter()
        formatter.allowedUnits = timeFormatterOptions.allowedUnits
        formatter.unitsStyle = timeFormatterOptions.unitsStyle
        formatter.includesTimeRemainingPhrase = timeFormatterOptions.includesTimeRemainingPhrase
        formatter.includesApproximationPhrase = timeFormatterOptions.includesApproximationPhrase
        privateTimeFormatterOptions = timeFormatterOptions
    }
    
    func string(from timeInterval: TimeInterval) -> String? {
        let seconds = timeInterval < 60 && shouldShowExact ? timeInterval.rounded(.down) :
        (timeInterval / divider).rounded() * divider
        return formatter.string(from: seconds)
    }
    
}
