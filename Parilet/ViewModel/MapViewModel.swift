//
//  MapViewModel.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 24.11.2022.
//

import MapboxMaps
import RxSwift
import RxCocoa

protocol MapViewModelType {
    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
    
    typealias Annotations = [PointAnnotation]
    typealias Records = [Record]
}

final class MapViewModel: MapViewModelType {
    
    struct Input {
        let annotationPickedByUser: PublishRelay<Annotation>
    }
    
    struct Output {
        let mapAnnotations: Driver<Annotations>
        let route: Driver<()>
    }
    
    let input: Input
    let output: Output
    
    private let annotationPickedByUser = PublishRelay<Annotation>()
    
    private let sanisetteApiClient = APIClient<SanisetteData>()
    private let routeClient = RouteClient()
    private let locationManager: LocationManager
    private let rxLocationProviderDelegate = RxLocationProviderDelegate()
    
    init(location: LocationManager) {
        locationManager = location
        locationManager.locationProvider.setDelegate(rxLocationProviderDelegate)
        
        let mapAnnotations = sanisetteApiClient.getData()
            .map { data in
                data.records.map { PointAnnotation(withRecord: $0) }
            }
            .asDriver(onErrorJustReturn: [])
        
        let route = annotationPickedByUser
            .withLatestFrom(rxLocationProviderDelegate.latestLocation) { pickedAnnotation, latestLocation in
                print(pickedAnnotation, latestLocation)
            }
            .asDriver(onErrorJustReturn: ())
        
        input = Input(annotationPickedByUser: annotationPickedByUser)
        output = Output(mapAnnotations: mapAnnotations, route: route)
    }
    
}
