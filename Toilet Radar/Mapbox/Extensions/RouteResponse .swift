//
//  RouteResponse .swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 21.03.2023.
//

import MapboxDirections

extension RouteResponse {
    var primaryRouteIfPresent: MapboxDirections.Route? {
        routes?.first
    }
}
