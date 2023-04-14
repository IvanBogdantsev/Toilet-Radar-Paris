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
    func viewDidLoad()
    func didSelectAnnotation(_ annotation: PointAnnotation)
    func shouldTrackLocation(_ shouldTrackLocation: Bool)
}

protocol MapViewModelOutputs {
    /// an array of PointAnnotations. Used to populate the map with annotations.
    typealias PointAnnotations = [PointAnnotation]
    /// an array of PolylineAnnotations. Used to construct polyline one the map.
    typealias PolylineAnnotations = [PolylineAnnotation]
    /// Typealias that resolves conflict between 'RxSwift.Observable' and 'Mapbox.Observable'
    typealias RxObservable = RxSwift.Observable
    typealias Empty = ()
    
    var customLocationProvider: Single<LocationProvider>! { get }
    var initialCameraOptions: RxObservable<CameraOptions>! { get }
    var mapAnnotations: RxObservable<PointAnnotations>! { get }
    var destinationHighlights: RxObservable<Destination>! { get }
    var routeHighlights: RxObservable<Route>! { get }
    var routeHighlightsRefreshing: RxObservable<Bool>! { get }
    var polyline: RxObservable<PolylineAnnotations>! { get }
    var updatedCameraOptions: RxObservable<CameraOptions>! { get }
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
        
        let updatedRouteProgress = distinctLocation
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
        
        self.routeHighlightsRefreshing = RxObservable
            .merge(distinctAnnotation.map { _ in true }, routeResponse.map { _ in false}
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)) // makes UI smoother
        
        self.polyline = routeResponse
            .backgroundCompactMap(qos: .userInteractive) { PolylineAnnotation(withRouteResponse: $0) }
            .map { [$0] }
            .race(updatedPolyline)
        
        self.initialCameraOptions = RxSwift.Observable.zip(distinctLocation, viewDidLoadProperty)
            .map { CameraOptions(center: $0.0.coordinate, zoom: 15) }
                
        self.updatedCameraOptions = distinctLocation.combineWithLatest(shouldTrackLocationProperty)
            .filter { $0.1 }
            .map { CameraOptions(center: $0.0.coordinate, zoom: 15) }
        
        self.isTrackingLocation = shouldTrackLocationProperty.distinctUntilChanged { $0 == $1 }
        
        self.error = errorRouter.error
            .map { error in
                error.localizedDescription
            }
    }
    
    private let viewDidLoadProperty = PublishRelay<Empty>()
    func viewDidLoad() {
        viewDidLoadProperty.accept(Empty())
    }
    
    private let selectedAnnotation = PublishRelay<PointAnnotation>()
    func didSelectAnnotation(_ annotation: PointAnnotation) {
        selectedAnnotation.accept(annotation)
    }
    
    private let shouldTrackLocationProperty = PublishRelay<Bool>()
    func shouldTrackLocation(_ trackingEnabled: Bool) {
        shouldTrackLocationProperty.accept(trackingEnabled)
    }
    
    var customLocationProvider: Single<MapboxMaps.LocationProvider>!
    var initialCameraOptions: RxObservable<CameraOptions>!
    var mapAnnotations: RxObservable<PointAnnotations>!
    var destinationHighlights: RxObservable<Destination>!
    var routeHighlights: RxObservable<Route>!
    var routeHighlightsRefreshing: RxObservable<Bool>!
    var polyline: RxObservable<PolylineAnnotations>!
    var updatedCameraOptions: RxObservable<CameraOptions>!
    var isTrackingLocation: RxObservable<Bool>!
    var error: RxObservable<String>!
    
    var inputs: MapViewModelInputs { self }
    var outputs: MapViewModelOutputs { self }
    
}
