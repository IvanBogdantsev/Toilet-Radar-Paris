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
        leg.steps.prefix(upTo: stepIndex).map { $0.distance }.reduce(0, +) + currentStepProgress.distanceTraveled
    }
    
    var durationRemaining: TimeInterval {
        remainingSteps.map { $0.expectedTravelTime }.reduce(0, +) + currentStepProgress.durationRemaining
    }
    
    var distanceRemaining: CLLocationDistance {
        remainingSteps.map { $0.distance }.reduce(0, +) + currentStepProgress.distanceRemaining
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
        Array(leg.steps.suffix(from: stepIndex + 1))
    }
    
    var currentStep: RouteStep {
        leg.steps[stepIndex]
    }
    
    var currentStepProgress: RouteStepProgress
    
    init(leg: RouteLeg, stepIndex: Int = 0) {
        precondition(leg.steps.indices.contains(stepIndex), "It's not possible to set the stepIndex: \(stepIndex) when it's higher than steps count \(leg.steps.count) or not included.")
        
        self.leg = leg
        self.stepIndex = stepIndex
        
        currentStepProgress = RouteStepProgress(step: leg.steps[stepIndex])
    }   
    
}
