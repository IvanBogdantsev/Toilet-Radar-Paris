//
//  PolylineAnnotation.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 06.01.2023.
//

import MapboxMaps
import MapboxDirections

extension PolylineAnnotation {
    init?(with routeResponse: RouteResponse) {
        guard let lineString = routeResponse.routes?.first?.shape else { return nil }
        self.init(lineString: lineString)
        self.lineColor = StyleColor(UIColor.darkGray) // subject to change
        self.lineWidth = 5 // subject to change
        self.lineJoin = .round
    }
}

