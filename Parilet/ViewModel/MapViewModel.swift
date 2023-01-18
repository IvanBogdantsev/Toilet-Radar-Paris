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
}

final class MapViewModel: MapViewModelType {
    
    struct Input {
        let annotationPickedByUser: PublishRelay<PointAnnotation>
    }
    
    struct Output {
        let customLocationProvider: Single<LocationProvider>
        let mapAnnotations: Driver<PointAnnotations>
        let route: Driver<PolylineAnnotations>
        let error: Driver<String>
    }
    
    var input: Input!
    var output: Output!
    
    private let annotationPickedByUser = PublishRelay<PointAnnotation>()
    
    private let sanisetteApiClient = APIClient<SanisetteData>()
    private let routeClient = RouteClient()
    private let locationProvider: ThisAppLocationProvider!
    
    init() {
        locationProvider = ThisAppLocationProvider()
        let errorRouter = ErrorRouter()
        
        let customLocationProvider = locationProvider.observableSelf
        
        let mapAnnotations = sanisetteApiClient.getData()
            .rerouteError(errorRouter)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .map { data in
                data.records.map { PointAnnotation(withRecord: $0) }
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let route = annotationPickedByUser
            .distinctUntilChanged { $0.id == $1.id }
            .withLatestFrom(locationProvider.didUpdateLatestLocation) { ($0, $1) }
            .flatMap { annotation, location in
                self.routeClient.getRoute(origin: annotation.coordinate, destination: location.coordinate)
                    .rerouteError(errorRouter)
                    .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                    .map { routeResponse in
                        PolylineAnnotation(withRouteResponse: routeResponse)
                    }
                    .compactMap { $0 }
                    .map { [$0] }
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let error = errorRouter.error
            .map { error in
                error.localizedDescription
            }
            .asDriver(onErrorDriveWith: .empty())
        
        input = Input(annotationPickedByUser: annotationPickedByUser)
        output = Output(customLocationProvider: customLocationProvider,
                        mapAnnotations: mapAnnotations,
                        route: route,
                        error: error)
    }
    
}
