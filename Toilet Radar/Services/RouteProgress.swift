//
//  RouteProgress.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 17.03.2023.
//

import CoreLocation
import MapboxDirections
import MapboxMaps

/// `RouteProgress` stores the user’s progress along the route
final class RouteProgress {
    
    var distanceTraveled: CLLocationDistance {
        route.distance - distanceRemaining
    }
    
    var fractionTraveled: Double {
        guard route.distance > 0 else { return 1 }
        return distanceTraveled / route.distance
    }
    
    var durationRemaining: TimeInterval {
        (1 - fractionTraveled) * route.expectedTravelTime
    }
    /// Collections of remaining route positions
    var remainingShape: LineString? {
        guard let finalRouteCoordinate else { return nil }
        return shape?.trimmed(from: finalRouteCoordinate, distance: -distanceRemaining)
    }
    
    private(set) var distanceRemaining: CLLocationDistance = 0
    /// Current route
    private(set) var route: MapboxDirections.Route
    /// Collections of current route positions
    private lazy var shape: LineString? = {
        route.shape
    }()
    
    private lazy var finalRouteCoordinate: LocationCoordinate2D? = {
        shape?.coordinates.last
    }()
    /// Creates an instance of RouteProgress.
    ///  - Parameter route: MapboxDirections.Route.
    ///  - Returns: An instance of RouteProgress, or nil if route is nil.
    init?(route: MapboxDirections.Route?) {
        guard let route else { return nil }
        self.route = route
    }
    
    func updateDistanceTraveled(with location: CLLocation) {
        guard let shape else { return }
        if let closestCoordinate = shape.closestCoordinate(to: location.coordinate) {
            let remainingDistance = shape.distance(from: closestCoordinate.coordinate)!
            let distanceTraveled = route.distance - remainingDistance
            self.distanceRemaining = route.distance - distanceTraveled
        }
    }
    
}
