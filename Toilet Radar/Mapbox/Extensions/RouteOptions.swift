//
//  RouteOptions.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 19.03.2023.
//

import MapboxDirections

extension RouteOptions {
    func waypoints(fromLegAt legIndex: Int) -> ([Waypoint], [Waypoint]) {
        let legSeparators = waypoints.filterKeepingFirstAndLast { $0.separatesLegs }
        let viaPointsByLeg = waypoints.splitExceptAtStartAndEnd(omittingEmptySubsequences: false) { $0.separatesLegs }
            .dropFirst()
        
        let reconstitutedWaypoints = zip(legSeparators, viaPointsByLeg).dropFirst(legIndex).map { [$0.0] + $0.1 }
        let legWaypoints = reconstitutedWaypoints.first ?? []
        let subsequentWaypoints = reconstitutedWaypoints.dropFirst()
        return (legWaypoints, subsequentWaypoints.flatMap { $0 })
    }
}
