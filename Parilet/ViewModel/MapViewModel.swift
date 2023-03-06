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

    
    init() {
        self.customLocationProvider = locationProvider.observableSelf
        
        self.mapAnnotations = sanisetteApiClient.getMapPoints()
            .rerouteError(errorRouter)
            .backgroundMap(qos: .userInteractive) { data in
                data.records.map { PointAnnotation(withRecord: $0) }
            }
        
        let distinctAnnotation = selectedAnnotation
            .distinctUntilChanged { $0.coordinate == $1.coordinate }
        
        self.destinationHighlights = distinctAnnotation
            .map { Destination(destinationInfo: $0.userInfoUnwrapped) }
        
        let routeResponse = distinctAnnotation
            .withLatestFrom(locationProvider.didUpdateLatestLocation) { ($0, $1) }
            .flatMap { self.routeClient.getRoute(between: [$0.coordinate, $1.coordinate])
                .rerouteError(self.errorRouter) }
        
        self.routeHighlights = routeResponse.compactMap { Route(withRouteResponse: $0) }
        
        self.polyline = routeResponse
            .backgroundCompactMap(qos: .userInteractive) { PolylineAnnotation(withRouteResponse: $0) }
            .map { [$0] }
        
        self.error = errorRouter.error
            .map { error in
                error.localizedDescription
            }
    }
    
    private let selectedAnnotation = PublishRelay<PointAnnotation>()
    func didSelectAnnotation(_ annotation: PointAnnotation) {
        selectedAnnotation.accept(annotation)
    }
    
    var customLocationProvider: RxSwift.Single<MapboxMaps.LocationProvider>!
    var mapAnnotations: RxSwift.Observable<PointAnnotations>!
    var destinationHighlights: RxObservable<Destination>!
    var routeHighlights: RxObservable<Route>!
    var polyline: RxObservable<PolylineAnnotations>!
    var error: RxObservable<String>!
    
    var inputs: MapViewModelInputs { self }
    var outputs: MapViewModelOutputs { self }
    
}
