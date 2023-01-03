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
    
    typealias Annotations = [PointAnnotation]
    typealias Records = [Record]
}

final class MapViewModel: MapViewModelType {
    
    struct Input {
        let annotationPickedByUser: PublishRelay<Annotation>
    }
    
    struct Output {
        let mapAnnotations: Driver<Annotations>
        let route: Driver<RouteResponse>
    }
    
    var input: Input!
    var output: Output!
    
    private let annotationPickedByUser = PublishRelay<Annotation>()
    
    private let sanisetteApiClient = APIClient<SanisetteData>()
    private let routeClient = RouteClient()
    private let locationManager: LocationManager
    
    init(location: LocationManager) {
        locationManager = location
        
        let mapAnnotations = sanisetteApiClient.getData()
            .map { data in
                data.records.map { PointAnnotation(withRecord: $0) }
            }
            .asDriver(onErrorJustReturn: [])
        
        let route = annotationPickedByUser
            .flatMap { annotationPickedByUser in
                self.routeClient.getRoute(origin: (annotationPickedByUser as! PointAnnotation).coordinate,
                                          destination: self.locationManager.latestLocation!.coordinate)
            }
            .asDriver(onErrorDriveWith: .never())
        
        input = Input(annotationPickedByUser: annotationPickedByUser)
        output = Output(mapAnnotations: mapAnnotations, route: route)
    }
    
}
