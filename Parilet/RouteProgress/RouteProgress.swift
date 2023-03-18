//
//  RouteProgress.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 17.03.2023.
//

import CoreLocation
import MapboxDirections
import MapboxMaps

extension RouteLeg {
    public var shape: LineString {
        return steps.dropFirst().reduce(into: steps.first?.shape ?? LineString([])) { (result, step) in
            result.coordinates += (step.shape?.coordinates ?? []).dropFirst()
        }
    }
}

extension RouteOptions {
    func waypoints(fromLegAt legIndex: Int) -> ([Waypoint], [Waypoint]) {
        // The first and last waypoints always separate legs. Make exceptions for these waypoints instead of modifying them by side effect.
        let legSeparators = waypoints.filterKeepingFirstAndLast { $0.separatesLegs }
        let viaPointsByLeg = waypoints.splitExceptAtStartAndEnd(omittingEmptySubsequences: false) { $0.separatesLegs }
            .dropFirst() // No leg precedes first separator.
        
        let reconstitutedWaypoints = zip(legSeparators, viaPointsByLeg).dropFirst(legIndex).map { [$0.0] + $0.1 }
        let legWaypoints = reconstitutedWaypoints.first ?? []
        let subsequentWaypoints = reconstitutedWaypoints.dropFirst()
        return (legWaypoints, subsequentWaypoints.flatMap { $0 })
    }
}

extension Array {
    /**
     - seealso: Array.filter(_:)
     */
    public func filterKeepingFirstAndLast(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        return try enumerated().filter {
            try isIncluded($0.element) || $0.offset == 0 || $0.offset == indices.last
        }.map { $0.element }
    }
    
    /**
     - seealso: Array.split(maxSplits:omittingEmptySubsequences:whereSeparator:)
     */
    public func splitExceptAtStartAndEnd(maxSplits: Int = .max, omittingEmptySubsequences: Bool = true, whereSeparator isSeparator: (Element) throws -> Bool) rethrows -> [ArraySlice<Element>] {
        return try enumerated().split(maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences) {
            try isSeparator($0.element) || $0.offset == 0 || $0.offset == indices.last
        }.map { $0.map { $0.element }.suffix(from: 0) }
    }
}
/**
 `RouteProgress` stores the user’s progress along a route.
 */
open class RouteProgress {
    private static let reroutingAccuracy: CLLocationAccuracy = 90
    
    /**
     Intializes a new `RouteProgress`.
     - parameter route: The route to follow.
     - parameter options: The route options that were attached to the route request.
     - parameter legIndex: Zero-based index indicating the current leg the user is on.
     - parameter routeShapeIndex: Index relative to route shape, representing the point the user is currently located at.
     - parameter legShapeIndex: Index relative to leg shape, representing the point the user is currently located at.
     */
    public init(route: MapboxDirections.Route, options: RouteOptions, legIndex: Int = 0, spokenInstructionIndex: Int = 0, routeShapeIndex: Int = 0, legShapeIndex: Int = 0) {
        self.route = route
        self.routeOptions = options
        self.legIndex = legIndex
        self.shapeIndex = routeShapeIndex
        self.currentLegProgress = RouteLegProgress(leg: route.legs[legIndex], stepIndex: 0, spokenInstructionIndex: spokenInstructionIndex, shapeIndex: legShapeIndex)
        
    }
    
    /**
     Current `RouteOptions`, optimized for rerouting.
     
     This method is useful for implementing custom rerouting. Resulting `RouteOptions` skip passed waypoints and include current user heading if possible.
     
     - parameter location: Current user location. Treated as route origin for rerouting.
     - returns: Modified `RouteOptions`.
     */
    public func reroutingOptions(from location: CLLocation) -> RouteOptions {
        let oldOptions = routeOptions
        let user = Waypoint(coordinate: location.coordinate)
        
        // A pedestrian can turn on a dime; there's no problem with a route that starts out by turning the pedestrian around.
        let transportType = currentLegProgress.currentStep.transportType
        if transportType != .walking && location.course >= 0 {
            user.heading = location.course
            user.headingAccuracy = RouteProgress.reroutingAccuracy
        }
        let newWaypoints = [user] + remainingWaypointsForCalculatingRoute()
        let newOptions: RouteOptions = oldOptions
        
        newOptions.waypoints = newWaypoints
        
        return newOptions
    }
    
    // MARK: Route Statistics
    
    /**
     Returns the current `RouteOptions`.
     */
    public let routeOptions: RouteOptions
    
    /**
     Total distance traveled by user along all legs.
     */
    public var distanceTraveled: CLLocationDistance {
        return route.legs.prefix(upTo: legIndex).map { $0.distance }.reduce(0, +) + currentLegProgress.distanceTraveled
    }
    
    /**
     Total seconds remaining on all legs.
     */
    public var durationRemaining: TimeInterval {
        return route.legs.suffix(from: legIndex + 1).map { $0.expectedTravelTime }.reduce(0, +) + currentLegProgress.durationRemaining
    }
    
    /**
     Number between 0 and 1 representing how far along the `Route` the user has traveled.
     */
    public var fractionTraveled: Double {
        guard route.distance > 0 else { return 1 }
        return distanceTraveled / route.distance
    }
    
    /**
     Total distance remaining in meters along route.
     */
    public var distanceRemaining: CLLocationDistance {
        return max(route.distance - distanceTraveled, 0)
    }
    
    /**
     The waypoints remaining on the current route.
     
     This property does not include waypoints whose `Waypoint.separatesLegs` property is set to `false`.
     */
    public var remainingWaypoints: [Waypoint] {
        return route.legs.suffix(from: legIndex).compactMap { $0.destination }
    }
    
    /**
     The waypoints remaining on the current route, including any waypoints that do not separate legs.
     */
    func remainingWaypointsForCalculatingRoute() -> [Waypoint] {
        let (currentLegViaPoints, remainingWaypoints) = routeOptions.waypoints(fromLegAt: legIndex)
        let currentLegRemainingViaPoints = currentLegProgress.remainingWaypoints(among: currentLegViaPoints)
        return currentLegRemainingViaPoints + remainingWaypoints
    }
    
    /**
     Upcoming `RouteAlerts` as reported by the navigation engine.
     
     The contents of the array depend on user's current progress along the route and are modified on each location update. This array contains only the alerts that the user has not passed. Some events may have non-zero length and are also included while the user is traversing it. You can use this property to get information about incoming points of interest.
     */
    
    /**
     Returns an array of `CLLocationCoordinate2D` of the coordinates along the current step and any adjacent steps.
     
     - important: The adjacent steps may be part of legs other than the current leg.
     */
    public var nearbyShape: LineString {
        let priorCoordinates = priorStep?.shape?.coordinates.dropLast() ?? []
        let currentShape = currentLegProgress.currentStep.shape
        let upcomingCoordinates = upcomingStep?.shape?.coordinates.dropFirst() ?? []
        if let currentShape = currentShape, priorCoordinates.isEmpty && upcomingCoordinates.isEmpty {
            return currentShape
        }
        return LineString(priorCoordinates + (currentShape?.coordinates ?? []) + upcomingCoordinates)
    }
    
    // MARK: Updating the RouteProgress
    /**
     Returns the current `Route`.
     */
    public var route: MapboxDirections.Route
    
    /**
     Updates the current route with attributes from the given skeletal route.
     */
    public func refreshRoute(with refreshedRoute: RouteRefreshSource, at location: CLLocation) {
        route.refreshLegAttributes(from: refreshedRoute)
        route.refreshLegIncidents(from: refreshedRoute)
        commonRefreshRoute(at: location)
    }
    
    public func refreshRoute(with refreshedRoute: RouteRefreshSource, at location: CLLocation, legIndex: Int, legShapeIndex: Int) {
        route.refreshLegAttributes(from: refreshedRoute, legIndex: legIndex, legShapeIndex: legShapeIndex)
        route.refreshLegIncidents(from: refreshedRoute, legIndex: legIndex, legShapeIndex: legShapeIndex)
        commonRefreshRoute(at: location)
    }
    
    private func commonRefreshRoute(at location: CLLocation) {
        currentLegProgress = RouteLegProgress(leg: route.legs[legIndex],
                                              stepIndex: currentLegProgress.stepIndex,
                                              spokenInstructionIndex: currentLegProgress.currentStepProgress.spokenInstructionIndex,
                                              intersectionIndex: currentLegProgress.currentStepProgress.intersectionIndex)
        updateDistanceTraveled(with: location)
    }
    
    /**
     Index relative to route shape, representing the point the user is currently located at.
     */
    public internal(set) var shapeIndex: Int
    
    /**
     Increments the progress according to new location specified.
     - parameter location: Updated user location.
     */
    public func updateDistanceTraveled(with location: CLLocation) {
        let stepProgress = currentLegProgress.currentStepProgress
        let step = stepProgress.step
        
        //Increment the progress model
        guard let polyline = step.shape else {
            preconditionFailure("Route steps used for navigation must have shape data")
        }
        if let closestCoordinate = polyline.closestCoordinate(to: location.coordinate) {
            let remainingDistance = polyline.distance(from: closestCoordinate.coordinate)!
            let distanceTraveled = step.distance - remainingDistance
            stepProgress.distanceTraveled = distanceTraveled
        }
    }
    /**
     Update the distance to intersection according to new location specified.
     - parameter location: Updated user location.
     */
    private func updateDistanceToIntersection() {
        guard var intersections = currentLegProgress.currentStepProgress.step.intersections else { return }
        
        // The intersections array does not include the upcoming maneuver intersection.
        if let upcomingIntersection = currentLegProgress.upcomingStep?.intersections?.first {
            intersections += [upcomingIntersection]
        }
        currentLegProgress.currentStepProgress.intersectionsIncludingUpcomingManeuverIntersection = intersections
        
        if let shape = currentLegProgress.currentStep.shape,
           let upcomingIntersection = currentLegProgress.currentStepProgress.upcomingIntersection,
           let coordinateOnStep = shape.coordinateFromStart(
            distance: currentLegProgress.currentStepProgress.distanceTraveled
           ) {
            currentLegProgress.currentStepProgress.userDistanceToUpcomingIntersection = shape.distance(
                from: coordinateOnStep,
                to: upcomingIntersection.location
            )
        }
        
        updateIntersectionDistances()
    }
    
    func updateIntersectionDistances() {
        guard currentLegProgress.currentStepProgress.intersectionDistances == nil else { return }
        
        currentLegProgress.currentStepProgress.intersectionDistances = [CLLocationDistance]()
        if let shape = currentLegProgress.currentStep.shape,
           let intersections = currentLegProgress.currentStep.intersections {
            let distances: [CLLocationDistance] = intersections.compactMap { shape.distance(from: shape.coordinates.first, to: $0.location) }
            currentLegProgress.currentStepProgress.intersectionDistances = distances
        }
    }
    
    // MARK: Leg Statistics
    
    /**
     Index representing current `RouteLeg`.
     */
    public var legIndex: Int {
        didSet {
            assert(legIndex >= 0 && legIndex < route.legs.endIndex)
            // TODO: Set stepIndex to 0 or last index based on whether leg index was incremented or decremented.
            currentLegProgress = RouteLegProgress(leg: currentLeg)
        }
    }
    
    /**
     If waypoints are provided in the `Route`, this will contain which leg the user is on.
     */
    public var currentLeg: RouteLeg {
        return route.legs[legIndex]
    }
    
    /**
     Returns the remaining legs left on the current route
     */
    public var remainingLegs: [RouteLeg] {
        return Array(route.legs.suffix(from: legIndex + 1))
    }
    
    /**
     Returns true if `currentLeg` is the last leg.
     */
    public var isFinalLeg: Bool {
        guard let lastLeg = route.legs.last else { return false }
        return currentLeg == lastLeg
    }
    
    /**
     Returns the progress along the current `RouteLeg`.
     */
    public var currentLegProgress: RouteLegProgress
    
    public var priorLeg: RouteLeg? {
        return legIndex > 0 ? route.legs[legIndex - 1] : nil
    }
    
    /**
     The leg following the current leg along this route.
     
     If this leg is the last leg of the route, this property is set to nil.
     */
    public var upcomingLeg: RouteLeg? {
        return legIndex + 1 < route.legs.endIndex ? route.legs[legIndex + 1] : nil
    }
    
    // MARK: Step Statistics
    /**
     Returns the remaining steps left on the current route
     */
    public var remainingSteps: [RouteStep] {
        return currentLegProgress.remainingSteps + remainingLegs.flatMap { $0.steps }
    }
    
    /**
     The step prior to the current step along this route.
     
     The prior step may be part of a different RouteLeg than the current step. If the current step is the first step along the route, this property is set to nil.
     */
    public var priorStep: RouteStep? {
        return currentLegProgress.priorStep ?? priorLeg?.steps.last
    }
    
    /**
     The step following the current step along this route.
     
     The upcoming step may be part of a different RouteLeg than the current step. If it is the last step along the route, this property is set to nil.
     */
    public var upcomingStep: RouteStep? {
        return currentLegProgress.upcomingStep ?? upcomingLeg?.steps.first
    }
    
    // MARK: Leg Attributes
    
    /**
     Tuple containing a `CongestionLevel` and a corresponding `TimeInterval` representing the expected travel time for this segment.
     */
    public typealias TimedCongestionLevel = (CongestionLevel, TimeInterval)
    
    /**
     If the route contains both `segmentCongestionLevels` and `expectedSegmentTravelTimes`, this property is set to a deeply nested array of `TimeCongestionLevels` per segment per step per leg.
     */
    public private(set) var congestionTravelTimesSegmentsByStep: [[[TimedCongestionLevel]]] = []
    
    /**
     An dictionary containing a `TimeInterval` total per `CongestionLevel`. Only `CongestionLevel` founnd on that step will present. Broken up by leg and then step.
     */
    public private(set) var congestionTimesPerStep: [[[CongestionLevel: TimeInterval]]]  = [[[:]]]
    
    public var averageCongestionLevelRemainingOnLeg: CongestionLevel? {
        guard let coordinates = currentLegProgress.currentStepProgress.step.shape?.coordinates else {
            return .unknown
        }
        
        let coordinatesLeftOnStepCount = Int(floor((Double(coordinates.count)) * currentLegProgress.currentStepProgress.fractionTraveled))
        
        guard coordinatesLeftOnStepCount >= 0 else { return .unknown }
        
        guard legIndex < congestionTravelTimesSegmentsByStep.count,
              currentLegProgress.stepIndex < congestionTravelTimesSegmentsByStep[legIndex].count else { return .unknown }
        
        let congestionTimesForStep = congestionTravelTimesSegmentsByStep[legIndex][currentLegProgress.stepIndex]
        guard coordinatesLeftOnStepCount <= congestionTimesForStep.count else { return .unknown }
        
        let remainingCongestionTimesForStep = congestionTimesForStep.suffix(from: coordinatesLeftOnStepCount)
        let remainingCongestionTimesForRoute = congestionTimesPerStep[legIndex].suffix(from: currentLegProgress.stepIndex + 1)
        
        var remainingStepCongestionTotals: [CongestionLevel: TimeInterval] = [:]
        for stepValues in remainingCongestionTimesForRoute {
            for (key, value) in stepValues {
                remainingStepCongestionTotals[key] = (remainingStepCongestionTotals[key] ?? 0) + value
            }
        }
        
        for (segmentCongestion, segmentTime) in remainingCongestionTimesForStep {
            remainingStepCongestionTotals[segmentCongestion] = (remainingStepCongestionTotals[segmentCongestion] ?? 0) + segmentTime
        }
        
        if durationRemaining < 60 {
            return .unknown
        } else {
            if let max = remainingStepCongestionTotals.max(by: { a, b in a.value < b.value }) {
                return max.key
            } else {
                return .unknown
            }
        }
    }
    
}
