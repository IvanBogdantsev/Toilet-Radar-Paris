//
//  Route.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 02.03.2023.
//

import Foundation
import MapboxDirections


struct Route {
    typealias LocationDistance = Double
    
    let distance: LocationDistance
    let travelTime: TimeInterval
    
    init(distance: LocationDistance, travelTime: TimeInterval) {
        self.distance = distance
        self.travelTime = travelTime
    }
    
    init?(withRouteResponse routeResponse: RouteResponse) {
        guard let route = routeResponse.routes?.first else { return nil }
        self.init(distance: route.distance, travelTime: route.expectedTravelTime)
    }
}
