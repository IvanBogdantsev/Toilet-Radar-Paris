//
//  RouteLegProgress.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 17.03.2023.
//

import CoreLocation
import MapboxDirections

/// `RouteLegProgress` stores the user’s progress along a route leg
final class RouteLegProgress {
    
    let leg: RouteLeg
    var distanceTraveled: CLLocationDistance {
        return leg.steps.prefix(upTo: stepIndex).map { $0.distance }.reduce(0, +) + currentStepProgress.distanceTraveled
    }
    
    var durationRemaining: TimeInterval {
        return remainingSteps.map { $0.expectedTravelTime }.reduce(0, +) + currentStepProgress.durationRemaining
    }
    
    var distanceRemaining: CLLocationDistance {
        return remainingSteps.map { $0.distance }.reduce(0, +) + currentStepProgress.distanceRemaining
    }
    
    var fractionTraveled: Double {
        guard leg.distance > 0 else { return 1 }
        return distanceTraveled / leg.distance
    }
    
    var stepIndex: Int {
        didSet {
            precondition(leg.steps.indices.contains(stepIndex), "It's not possible to set the stepIndex: \(stepIndex) when it's higher than steps count \(leg.steps.count) or not included.")
            currentStepProgress = RouteStepProgress(step: currentStep)
        }
    }
    
    var remainingSteps: [RouteStep] {
        return Array(leg.steps.suffix(from: stepIndex + 1))
    }
    
    var currentStep: RouteStep {
        return leg.steps[stepIndex]
    }
    
    var currentStepProgress: RouteStepProgress
    
    init(leg: RouteLeg, stepIndex: Int = 0) {
        precondition(leg.steps.indices.contains(stepIndex), "It's not possible to set the stepIndex: \(stepIndex) when it's higher than steps count \(leg.steps.count) or not included.")
        
        self.leg = leg
        self.stepIndex = stepIndex
        
        currentStepProgress = RouteStepProgress(step: leg.steps[stepIndex])
    }
    /// The waypoints remaining on the current leg
    func remainingWaypoints(among waypoints: [Waypoint]) -> [Waypoint] {
        guard waypoints.count > 1 else {
            return []
        }
        let legPolyline = leg.shape
        guard let userCoordinateIndex = legPolyline.indexedCoordinateFromStart(distance: distanceTraveled)?.index else {
            // The leg is empty.
            return []
        }
        var slice = legPolyline
        var accumulatedCoordinates = 0
        return Array(waypoints.drop { (waypoint) -> Bool in
            let newSlice = slice.sliced(from: waypoint.coordinate)!
            accumulatedCoordinates += slice.coordinates.count - newSlice.coordinates.count
            slice = newSlice
            return accumulatedCoordinates <= userCoordinateIndex
        })
    }
    
}
