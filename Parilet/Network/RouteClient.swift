//
//  RouteClient.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 02.01.2023.
//

import MapboxDirections
import MapboxMaps
import RxSwift

final class RouteClient {
    /// Typealias that resolves conflict between 'RxSwift.Observable' and 'Mapbox.Observable'
    typealias RxObservable = RxSwift.Observable
    
    private var routeOptions: RouteOptions!
    
    func getRoute(origin: LocationCoordinate2D, destination: LocationCoordinate2D) -> RxObservable<RouteResponse> {
        routeOptions = RouteOptions(coordinates: [origin, destination], profileIdentifier: .walking)
        routeOptions.routeShapeResolution = .full
        return calculateRoute(with: routeOptions)
    }
    
    private func calculateRoute(with options: RouteOptions) -> RxObservable<RouteResponse> {
        return RxObservable<RouteResponse>.create { observer in
            let task = Directions.shared.calculate(options) { _, result in
                switch result {
                case .success(let response):
                    observer.onNext(response)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
}
