//
//  RouteStepProgress.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 17.03.2023.
//

import CoreLocation
import MapboxDirections

/// `RouteStepProgress` stores the user’s progress along a route step
final class RouteStepProgress {
    
    init(step: RouteStep) {
        self.step = step
    }
    
    let step: RouteStep
    var distanceTraveled: CLLocationDistance = 0
    var distanceRemaining: CLLocationDistance {
        return max(step.distance - distanceTraveled, 0)
    }
    
    var fractionTraveled: Double {
        guard step.distance > 0 else { return 1 }
        return distanceTraveled / step.distance
    }
    
    var durationRemaining: TimeInterval {
        return (1 - fractionTraveled) * step.expectedTravelTime
    }
    
}
