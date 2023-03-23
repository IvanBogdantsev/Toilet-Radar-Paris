//
//  RouteProgress.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 17.03.2023.
//

import CoreLocation
import MapboxDirections
import MapboxMaps

/// `RouteProgress` stores the user’s progress along a route
final class RouteProgress {
    
    init?(route: MapboxDirections.Route?, legIndex: Int = 0) {
        guard let route = route else { return nil }
        self.route = route
        self.legIndex = legIndex
        self.currentLegProgress = RouteLegProgress(leg: route.legs[legIndex], stepIndex: 0)
    }
    
    var distanceTraveled: CLLocationDistance {
        return route.legs.prefix(upTo: legIndex).map { $0.distance }.reduce(0, +) + currentLegProgress.distanceTraveled
    }
    
    var durationRemaining: TimeInterval {
        return route.legs.suffix(from: legIndex + 1).map { $0.expectedTravelTime }.reduce(0, +) + currentLegProgress.durationRemaining
    }
    
    var fractionTraveled: Double {
        guard route.distance > 0 else { return 1 }
        return distanceTraveled / route.distance
    }
    
    var distanceRemaining: CLLocationDistance {
        return max(route.distance - distanceTraveled, 0)
    }
    
    var remainingWaypoints: [Waypoint] {
        return route.legs.suffix(from: legIndex).compactMap { $0.destination }
    }
    
    var remainingShape: LineString? { // рефактор: форс и двойной вызов distanceRemaining
        return route.shape?.trimmed(from: (route.shape?.coordinates.last!)!, distance: -distanceRemaining)
    }
    
    var route: MapboxDirections.Route
    
    private func commonRefreshRoute(at location: CLLocation) {
        currentLegProgress = RouteLegProgress(leg: route.legs[legIndex],
                                              stepIndex: currentLegProgress.stepIndex)
        updateDistanceTraveled(with: location)
    }
    
    func updateDistanceTraveled(with location: CLLocation) {
        let stepProgress = currentLegProgress.currentStepProgress
        let step = stepProgress.step
        
        guard let polyline = step.shape else { fatalError() }
        if let closestCoordinate = polyline.closestCoordinate(to: location.coordinate) {
            let remainingDistance = polyline.distance(from: closestCoordinate.coordinate)!
            let distanceTraveled = step.distance - remainingDistance
            stepProgress.distanceTraveled = distanceTraveled
        } else {  }
    }
    
    var currentLegProgress: RouteLegProgress
    var legIndex: Int {
        didSet {
            assert(legIndex >= 0 && legIndex < route.legs.endIndex)
            currentLegProgress = RouteLegProgress(leg: currentLeg)
        }
    }
    
    var currentLeg: RouteLeg {
        return route.legs[legIndex]
    }
    
    var remainingLegs: [RouteLeg] {
        return Array(route.legs.suffix(from: legIndex + 1))
    }
    
}
