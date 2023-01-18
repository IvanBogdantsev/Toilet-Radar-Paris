//
//  LocationProvider.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 14.01.2023.
//

import MapboxMaps
import CoreLocation
import RxSwift

final class ThisAppLocationProvider: NSObject {
    /// Typealias that resolves conflict between 'RxSwift.Observable' and 'Mapbox.Observable'
    typealias RxObservable = RxSwift.Observable
    
    private var locationProvider: CLLocationManager
    
    private var privateLocationProviderOptions: LocationOptions {
        didSet {
            locationProvider.distanceFilter = privateLocationProviderOptions.distanceFilter
            locationProvider.desiredAccuracy = privateLocationProviderOptions.desiredAccuracy
            locationProvider.activityType = privateLocationProviderOptions.activityType
        }
    }
    
    let didUpdateLatestLocation = PublishSubject<CLLocation>()
    
    private weak var delegate: LocationProviderDelegate?

    var headingOrientation: CLDeviceOrientation {
        didSet { locationProvider.headingOrientation = headingOrientation }
    }
    
    lazy var observableSelf: Single<LocationProvider> = {
        return RxObservable<LocationProvider>.create { observer in
            observer.onNext(self)
            observer.onCompleted()
            return Disposables.create()
        }
        .asSingle()
    }()

    override init() {
        locationProvider = CLLocationManager()
        privateLocationProviderOptions = LocationOptions()
        headingOrientation = locationProvider.headingOrientation
        super.init()
        locationProvider.delegate = self
    }
    
}

extension ThisAppLocationProvider: LocationProvider {

    var locationProviderOptions: LocationOptions {
        get { privateLocationProviderOptions }
        set { privateLocationProviderOptions = newValue }
    }

    var authorizationStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationProvider.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }

    var accuracyAuthorization: CLAccuracyAuthorization {
        if #available(iOS 14.0, *) {
            return locationProvider.accuracyAuthorization
        } else {
            return .fullAccuracy
        }
    }

    var heading: CLHeading? {
        return locationProvider.heading
    }
    /// This method must be kept to avoid breaking the API. Has no effect if called directly.
    func setDelegate(_ delegate: LocationProviderDelegate) {
        guard self.delegate == nil else { return }
        self.delegate = delegate
    }

    func requestAlwaysAuthorization() {
        locationProvider.requestAlwaysAuthorization()
    }

    func requestWhenInUseAuthorization() {
        locationProvider.requestWhenInUseAuthorization()
    }

    @available(iOS 14.0, *)
    func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String) {
        locationProvider.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)
    }

    func startUpdatingLocation() {
        locationProvider.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationProvider.stopUpdatingLocation()
    }

    func startUpdatingHeading() {
        locationProvider.startUpdatingHeading()
    }

    func stopUpdatingHeading() {
        locationProvider.stopUpdatingHeading()
    }

    func dismissHeadingCalibrationDisplay() {
        locationProvider.dismissHeadingCalibrationDisplay()
    }
    
}

extension ThisAppLocationProvider: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.locationProvider(self, didUpdateLocations: locations)
        guard let latestLocation = locations.first else { return }
        didUpdateLatestLocation.onNext(latestLocation)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        delegate?.locationProvider(self, didUpdateHeading: heading)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationProvider(self, didFailWithError: error)
    }

    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        delegate?.locationProviderDidChangeAuthorization(self)
    }
}
