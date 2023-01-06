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
    
    typealias PointAnnotations = [PointAnnotation]
    typealias PolylineAnnotations = [PolylineAnnotation]
    typealias Records = [Record]
}

final class MapViewModel: MapViewModelType {
    
    struct Input {
        let annotationPickedByUser: PublishRelay<PointAnnotation>
    }
    
    struct Output {
        let mapAnnotations: Driver<PointAnnotations>
        let route: Driver<PolylineAnnotations>
    }
    
    var input: Input!
    var output: Output!
    
    private let annotationPickedByUser = PublishRelay<PointAnnotation>()
    
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
            .distinctUntilChanged {$0.id == $1.id}
            .flatMap { annotationPickedByUser in
                self.routeClient.getRoute(origin: annotationPickedByUser.coordinate, destination: self.locationManager.latestLocation!.coordinate) // разобраться как обойтись без форс-анврапа
            }
            .map { routeResponse in
                [PolylineAnnotation(with: routeResponse)!] // разобраться как обрабатывать нил с драйвом
            }
            .asDriver(onErrorJustReturn: [])
        
        input = Input(annotationPickedByUser: annotationPickedByUser)
        output = Output(mapAnnotations: mapAnnotations, route: route)
    }
    
}
