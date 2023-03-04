//
//  PolylineAnnotation.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 06.01.2023.
//

import MapboxMaps
import MapboxDirections

extension PolylineAnnotation {
    /// Creates an instance of PolylineAnnotation.
    ///  - Parameter routeResponse: Returned by the Mapbox Directions API RouteResponce.
    ///  - Returns: An instance of PolylineAnnotation, or nil if routeResponse shape property contains nil.
    init?(withRouteResponse routeResponse: RouteResponse) {
        guard let lineString = routeResponse.routes?.first?.shape else { return nil }
        self.init(lineString: lineString)
        self.lineColor = StyleColor(UIColor.blue)
        self.lineOpacity = 0.5
        self.lineWidth = 5
        self.lineJoin = .round
    }
}

