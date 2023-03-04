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
    
    init?(withRouteResponse routeResponse: RouteResponse) {
        guard let route = routeResponse.routes?.first else { return nil }
        self.distance = route.distance
        self.travelTime = route.expectedTravelTime
    }
}
