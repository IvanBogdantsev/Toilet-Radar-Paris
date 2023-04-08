//
//  MapViewModel.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 24.11.2022.
//

import MapboxDirections
import MapboxMaps
import RxSwift
import RxCocoa

protocol MapViewModelInputs {
    func didSelectAnnotation(_ annotation: PointAnnotation)
    func shouldTrackUserLocation(_ shouldTrackLocation: Bool)
}

protocol MapViewModelOutputs {
    /// an array of PointAnnotations. Used to populate the map with annotations.
    typealias PointAnnotations = [PointAnnotation]
    /// an array of PolylineAnnotations. Used to construct polyline one the map.
    typealias PolylineAnnotations = [PolylineAnnotation]
    /// Typealias that resolves conflict between 'RxSwift.Observable' and 'Mapbox.Observable'
    typealias RxObservable = RxSwift.Observable
    
    var customLocationProvider: Single<LocationProvider>! { get }
    var mapAnnotations: RxObservable<PointAnnotations>! { get }
    var destinationHighlights: RxObservable<Destination>! { get }
    var routeHighlights: RxObservable<Route>! { get }
    var polyline: RxObservable<PolylineAnnotations>! { get }
    var updatedCameraPosition: RxObservable<CLLocationCoordinate2D>! { get }
    var isTrackingLocation: RxObservable<Bool>! { get }
    var error: RxObservable<String>! { get }
}

protocol MapViewModelType {
    var inputs: MapViewModelInputs { get }
    var outputs: MapViewModelOutputs { get }
}

final class MapViewModel: MapViewModelType, MapViewModelInputs, MapViewModelOutputs {
    
    private let sanisetteApiClient = APIClient<SanisetteData>()
    private let routeClient = RouteClient()
    private var locationProvider: LocationProviderType = ThisAppLocationProvider()
    private let errorRouter = ErrorRouter()
    private var routeProgress: RouteProgress?
    
    init() {
        self.customLocationProvider = locationProvider.observableSelf
        
        self.mapAnnotations = sanisetteApiClient.getData()
            .backgroundMap(qos: .userInteractive) { $0.records.map { PointAnnotation(withRecord: $0) } }
            .rerouteError(errorRouter)
        
        let distinctAnnotation = selectedAnnotation
            .distinctUntilChanged { $0.coordinate == $1.coordinate }
            .share()
        
        self.destinationHighlights = distinctAnnotation
            .map { Destination(destinationInfo: $0.userInfoUnwrapped) }
        
        let distinctLocation = locationProvider.didUpdateLatestLocation
            .distinctUntilChanged { $0 == $1 }
            .share()
        
        let routeResponse = distinctAnnotation
            .withLatestFrom(distinctLocation) { ($0, $1) }
            .flatMap { self.routeClient.getRoute(from: $1.coordinate, to: $0.coordinate)
                .rerouteError(self.errorRouter) }
            .do { self.routeProgress = RouteProgress(route: $0.primaryRouteIfPresent) }
            .share()
        
        let updatedRouteProgress = distinctLocation // filter, accuracy
            .backgroundMap(qos: .userInteractive) { self.routeProgress?.updateDistanceTraveled(with: $0) }
            .compactMap { self.routeProgress }
            .share()
        
        let updatedRoute = updatedRouteProgress
            .backgroundMap(qos: .userInteractive) { Route(distance: $0.distanceRemaining,
                                                          travelTime: $0.durationRemaining) }
        
        let updatedPolyline = updatedRouteProgress
            .backgroundCompactMap(qos: .userInteractive) { $0.remainingShape }
            .backgroundMap(qos: .userInteractive) { PolylineAnnotation(withLineString: $0) }
            .map { [$0] }
        
        self.routeHighlights = routeResponse.compactMap { Route(withRouteResponse: $0) }
            .race(updatedRoute)
        
        self.polyline = routeResponse
            .backgroundCompactMap(qos: .userInteractive) { PolylineAnnotation(withRouteResponse: $0) }
            .map { [$0] }
            .race(updatedPolyline)
                
        self.updatedCameraPosition = distinctLocation.combineWithLatest(shouldTrackLocation)
            .filter { $0.1 }
            .map { $0.0.coordinate }
        
        self.isTrackingLocation = shouldTrackLocation.distinctUntilChanged { $0 == $1 }
        
        self.error = errorRouter.error
            .map { error in
                error.localizedDescription
            }
    }
    
    private let selectedAnnotation = PublishRelay<PointAnnotation>()
    func didSelectAnnotation(_ annotation: PointAnnotation) {
        selectedAnnotation.accept(annotation)
    }
    
    private let shouldTrackLocation = PublishRelay<Bool>()
    func shouldTrackUserLocation(_ trackingEnabled: Bool) {
        shouldTrackLocation.accept(trackingEnabled)
    }
    
    var customLocationProvider: Single<MapboxMaps.LocationProvider>!
    var mapAnnotations: RxObservable<PointAnnotations>!
    var destinationHighlights: RxObservable<Destination>!
    var routeHighlights: RxObservable<Route>!
    var polyline: RxObservable<PolylineAnnotations>!
    var updatedCameraPosition: RxObservable<CLLocationCoordinate2D>!
    var isTrackingLocation: RxObservable<Bool>!
    var error: RxObservable<String>!
    
    var inputs: MapViewModelInputs { self }
    var outputs: MapViewModelOutputs { self }
    
}
