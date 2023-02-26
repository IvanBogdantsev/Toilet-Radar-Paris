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

protocol MapViewModelType {
    associatedtype Input
    associatedtype Output
    
    var input: Input! { get }
    var output: Output! { get }
    /// an array of PointAnnotations. Used to populate the map with annotations.
    typealias PointAnnotations = [PointAnnotation]
    /// an array of PolylineAnnotations. Used to construct polyline one the map.
    typealias PolylineAnnotations = [PolylineAnnotation]
    /// Typealias that resolves conflict between 'RxSwift.Observable' and 'Mapbox.Observable'
    typealias RxObservable = RxSwift.Observable
}

final class MapViewModel: MapViewModelType {
    
    struct Input {
        let annotationPickedByUser: PublishRelay<PointAnnotation>
    }
    
    struct Output {
        let customLocationProvider: Single<LocationProvider>
        let mapAnnotations: RxObservable<PointAnnotations>
        let route: RxObservable<PolylineAnnotations>
        let error: RxObservable<String>
    }
    
    var input: Input!
    var output: Output!
        
    private let annotationPickedByUser = PublishRelay<PointAnnotation>()
    
    private let sanisetteApiClient = APIClient<SanisetteData>()
    private let routeClient = RouteClient()
    private var locationProvider: LocationProviderType = ThisAppLocationProvider()
    
    init() {
        let errorRouter = ErrorRouter()
        let locationOptions = LocationOptions(distanceFilter: kCLHeadingFilterNone,
                                              desiredAccuracy: kCLLocationAccuracyBest,
                                              activityType: .fitness)
        locationProvider.locationProviderOptions = locationOptions
        
        let customLocationProvider = locationProvider.observableSelf
        
        let mapAnnotations = sanisetteApiClient.getData()
            .rerouteError(errorRouter)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive)) // backgroundmap
            .map { data in
                data.records.map { PointAnnotation(withRecord: $0) }
            }
        
        let route = annotationPickedByUser
            .distinctUntilChanged { $0.id == $1.id }
            .withLatestFrom(locationProvider.didUpdateLatestLocation) { ($0, $1) }
            .flatMap { annotation, location in // weak в замыканиях
                self.routeClient.getRoute(origin: annotation.coordinate, destination: location.coordinate)
                    .rerouteError(errorRouter)
                    .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                    .map { routeResponse in
                        PolylineAnnotation(withRouteResponse: routeResponse)
                    }
                    .compactMap { $0 }
                    .map { [$0] }
            }
        
        let error = errorRouter.error
            .map { error in
                error.localizedDescription
            }
        
        input = Input(annotationPickedByUser: annotationPickedByUser)
        output = Output(customLocationProvider: customLocationProvider,
                        mapAnnotations: mapAnnotations,
                        route: route,
                        error: error)
    }
    
}
