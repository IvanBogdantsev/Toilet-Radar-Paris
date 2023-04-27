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
    /// Creates an instance of RouteProgress.
    ///  - Parameter route: MapboxDirections.Route.
    ///  - Returns: An instance of RouteProgress, or nil if route is nil.
    init?(route: MapboxDirections.Route?) {
        guard let route = route else { return nil }
        self.route = route
    }
    /// Collections of current route positions
    private lazy var shape: LineString? = {
        route.shape
    }()
    
    private lazy var finalRouteCoordinate: LocationCoordinate2D? = {
        shape?.coordinates.last
    }()
    
    var distanceTraveled: CLLocationDistance {
        route.distance - distanceRemaining
    }
    
    var durationRemaining: TimeInterval {
        (1 - fractionTraveled) * route.expectedTravelTime
    }
    
    var fractionTraveled: Double {
        guard route.distance > 0 else { return 1 }
        return distanceTraveled / route.distance
    }
    
    private(set) var distanceRemaining: CLLocationDistance = 0
    
    var remainingShape: LineString? {
        guard let finalRouteCoordinate = finalRouteCoordinate else { return nil }
        return shape?.trimmed(from: finalRouteCoordinate, distance: -distanceRemaining)
    }
    /// Current route
    private(set) var route: MapboxDirections.Route
    
    func updateDistanceTraveled(with location: CLLocation) {
        guard let polyline = shape else { return }
        if let closestCoordinate = polyline.closestCoordinate(to: location.coordinate) {
            let remainingDistance = polyline.distance(from: closestCoordinate.coordinate)!
            let distanceTraveled = route.distance - remainingDistance
            self.distanceRemaining = route.distance - distanceTraveled
        }
    }
    
}
