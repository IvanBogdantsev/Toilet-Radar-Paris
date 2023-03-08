//
//  LocationProvider.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 14.01.2023.
//

import MapboxMaps
import CoreLocation
import RxSwift

protocol LocationProviderType: LocationProvider {
    var observableSelf: Single<LocationProvider> { get }
    var didUpdateLatestLocation: PublishSubject<CLLocation> { get }
    /// Typealias that resolves conflict between 'RxSwift.Observable' and 'Mapbox.Observable'
    typealias RxObservable = RxSwift.Observable
}

final class ThisAppLocationProvider: NSObject, LocationProviderType {
    
    private var locationProvider: CLLocationManager
    
    private var options: LocationOptions {
        didSet {
            locationProvider.distanceFilter = options.distanceFilter
            locationProvider.desiredAccuracy = options.desiredAccuracy
            locationProvider.activityType = options.activityType
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

    init(locationOptions: LocationOptions = LocationOptions(distanceFilter: kCLDistanceFilterNone,                                                                     desiredAccuracy: kCLLocationAccuracyBest,
                                                            activityType: .fitness))
    {
        locationProvider = CLLocationManager()
        locationProvider.distanceFilter = locationOptions.distanceFilter
        locationProvider.desiredAccuracy = locationOptions.desiredAccuracy
        locationProvider.activityType = locationOptions.activityType
        headingOrientation = locationProvider.headingOrientation
        options = locationOptions
        super.init()
        locationProvider.delegate = self
    }
    
}

extension ThisAppLocationProvider {

    var locationProviderOptions: LocationOptions {
        get { options }
        set { options = newValue }
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
