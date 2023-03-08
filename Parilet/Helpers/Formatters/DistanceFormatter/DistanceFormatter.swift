//
//  DistanceFormatter.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 06.03.2023.
//

import MapKit

final class DistanceFormatter: DistanceFormatterProtocol {
    
    private let formatter: LengthFormatter
    
    private var options: DistanceFormatterOptions {
        didSet {
            formatter.unitStyle = options.unitStyle
        }
    }
    
    private var currentDistace: CLLocationDistance!
    
    private var unit: LengthFormatter.Unit { currentDistace > 1000 ? .kilometer : .meter }
    
    private var increment: Double {
        currentDistace > 1000 ? options.roundingAboveKm.rawValue : options.roundingBelowKm.rawValue
    }
    
    private var roundingThreshold: Double { options.shouldShowExactBelow.rawValue }
    
    var distanceFormatterOptions: DistanceFormatterOptions {
        get { options }
        set { options = newValue }
    }

    init(distanceFormatterOptions: DistanceFormatterOptions = DistanceFormatterOptions()) {
        formatter = LengthFormatter()
        formatter.unitStyle = distanceFormatterOptions.unitStyle
        options = distanceFormatterOptions
    }
        
    func string(from distance: CLLocationDistance) -> String? {
        currentDistace = distance
        
        var value = distance < roundingThreshold ? distance.rounded() :
        distance.roundedToClosestDivider(of: increment)
        if unit == .kilometer { value /= 1000 }
        return formatter.string(fromValue: value, unit: unit)
    }
    
}
