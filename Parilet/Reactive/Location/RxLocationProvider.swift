//
//  LocationProvider.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 29.12.2022.
//

import MapboxMaps
import RxSwift
import RxCocoa

final class RxLocationProviderDelegate: LocationProviderDelegate {
    
    let latestLocation = PublishRelay<CLLocationCoordinate2D>()
    
    func locationProvider(_ provider: MapboxMaps.LocationProvider, didUpdateLocations locations: [CLLocation]) {
        latestLocation.accept(locations[0].coordinate)
    }
    /// unused:
    func locationProvider(_ provider: MapboxMaps.LocationProvider, didUpdateHeading newHeading: CLHeading) {}
    
    func locationProvider(_ provider: MapboxMaps.LocationProvider, didFailWithError error: Error) {}
    
    func locationProviderDidChangeAuthorization(_ provider: MapboxMaps.LocationProvider) {}
        
}
