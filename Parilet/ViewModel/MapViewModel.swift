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
    func viewDidLoad()
    func didSelectAnnotation(_ annotation: PointAnnotation)
    func shouldTrackLocation(_ shouldTrackLocation: Bool)
}

protocol MapViewModelOutputs {
    /// an array of PointAnnotations. Used to populate the map with annotations.
    typealias PointAnnotations = [PointAnnotation]
    /// an array of PolylineAnnotations. Used to construct polyline one the map.
    typealias PolylineAnnotations = [PolylineAnnotation]
    /// Typealias that resolves conflict between 'RxSwift.Observable' and 'Mapbox.Observable'
    typealias RxObservable = RxSwift.Observable
    typealias Empty = ()
    
    var customLocationProvider: Single<LocationProvider>! { get }
    var initialCameraOptions: RxObservable<CameraOptions>! { get }
    var mapAnnotations: RxObservable<PointAnnotations>! { get }
    var isAuthorisedToUseLocation: RxObservable<Bool>! { get }
    var didDisableLocationServices: RxObservable<Empty>! { get }
    var promptToEnableLocation: RxObservable<UIAlertController>! { get }
    var isEnRoute: RxObservable<Bool>! { get }
    var routeHighlightsViewIsVisible: RxObservable<Bool>! { get }
    var onboardingMessage: RxObservable<OnboardingMessageAndComment>! { get }
    var destinationHighlights: RxObservable<Destination>! { get }
    var routeHighlights: RxObservable<Route>! { get }
    var routeHighlightsRefreshing: RxObservable<Bool>! { get }
    var polyline: RxObservable<PolylineAnnotations>! { get }
    var updatedCameraOptions: RxObservable<CameraOptions>! { get }
    var isTrackingLocation: RxObservable<Bool>! { get }
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
    private var routeProgress: RouteProgress?
    // ПОСМОТРЕТЬ ШЕЙР, ВИК СЕЛФ В КОНТРОЛЛЕРЕ, ВЕСЬ ЛИ UI В МЕЙНЕ, разобраться с withLatest и флетмап
    init() {
        self.customLocationProvider = locationProvider.observableSelf
        
        self.mapAnnotations = sanisetteApiClient.getData()
            .backgroundMap(qos: .userInteractive) { $0.records.map { PointAnnotation(withRecord: $0) } }
            .rerouteError(errorRouter)
        
        let distinctAnnotation = selectedAnnotation
            .distinctUntilChanged { $0.coordinate == $1.coordinate }
            .share()
        // TODO: route cancelling
        self.isEnRoute = distinctAnnotation.map { _ in true }
            .startWith(false)
            .share()
        
        self.onboardingMessage = BehaviorRelay(value: Messages.howToStartYourRoute).asObservable()
        
        self.destinationHighlights = distinctAnnotation
            .map { Destination(destinationInfo: $0.userInfoUnwrapped) }
        
        let isAuthorisedToUseLocation = locationProvider.isAuthorisedToUseLocation
            .distinctUntilChanged()
            .share()
        
        self.isAuthorisedToUseLocation = isAuthorisedToUseLocation
        
        self.didDisableLocationServices = isAuthorisedToUseLocation.filter { !$0 }.asEmpty()
            .do(onNext: { self.routeProgress = nil })
        
        self.routeHighlightsViewIsVisible = isEnRoute.withLatestFrom(isAuthorisedToUseLocation) { ($0, $1) }
            .map { $0.0 && $0.1 }
            .distinctUntilChanged()
            .startWith(false)// поменять имя свойства в мапвью
        
        let shouldPromptToEnableLocation = shouldTrackLocationProperty.filter { $0 }
            .withLatestFrom(isAuthorisedToUseLocation) { $1 }
            .filter { !$0 }
        
        self.promptToEnableLocation = shouldPromptToEnableLocation
            .map { _ in UIAlertController.promptToEnableLocation() }
        
        let distinctLocation = locationProvider.didUpdateLatestLocation
            .distinctUntilChanged { $0 == $1 }
            .share()
        
        let routeResponse = distinctAnnotation
            .withLatestFrom(isAuthorisedToUseLocation) { ($0, $1) }
            .filter { $0.1 }
            .map { $0.0 }
            .withLatestFrom(distinctLocation) { ($0, $1) }
            .flatMap { self.routeClient.getRoute(from: $1.coordinate, to: $0.coordinate)
                .rerouteError(self.errorRouter) }
            .do { self.routeProgress = RouteProgress(route: $0.primaryRouteIfPresent) }
            .share()
        
        let updatedRouteProgress = distinctLocation
            .backgroundMap(qos: .userInteractive) { self.routeProgress?.updateDistanceTraveled(with: $0) }
            .compactMap { self.routeProgress }
            .share()
        
        let updatedRoute = updatedRouteProgress
            .backgroundMap(qos: .userInteractive) { Route(distance: $0.distanceRemaining,
                                                          travelTime: $0.durationRemaining) }
        
        let updatedPolyline = updatedRouteProgress
            .backgroundCompactMap(qos: .userInteractive) { $0.remainingShape }
            .backgroundMap(qos: .userInteractive) { PolylineAnnotation(withLineString: $0) }
            .map { [$0] }
        
        self.routeHighlights = routeResponse.compactMap { Route(withRouteResponse: $0) }
            .race(updatedRoute)
        
        self.routeHighlightsRefreshing = RxObservable
            .merge(distinctAnnotation.map { _ in true }, routeResponse.map { _ in false }
                .delay(.milliseconds(500), scheduler: MainScheduler.instance)) // makes UI smoother
            .withLatestFrom(isAuthorisedToUseLocation) { ($0, $1) }
            .map { $0.0 && $0.1 }
        
        self.polyline = routeResponse
            .backgroundCompactMap(qos: .userInteractive) { PolylineAnnotation(withRouteResponse: $0) }
            .map { [$0] }
            .race(updatedPolyline)
        
        self.initialCameraOptions = RxObservable.zip(distinctLocation, viewDidLoadProperty)
            .map { CameraOptions(center: $0.0.coordinate, zoom: 15) }
        
        let canTrackLocation = shouldTrackLocationProperty.distinctUntilChanged()
            .combineWithLatest(isAuthorisedToUseLocation)
            .map { $0.0 && $0.1 }
        
        self.updatedCameraOptions = distinctLocation.combineWithLatest(canTrackLocation)
            .filter { $0.1 }
            .map { CameraOptions(center: $0.0.coordinate, zoom: 15) }
        
        self.isTrackingLocation = shouldTrackLocationProperty.combineWithLatest(isAuthorisedToUseLocation)
            .filter { $0.1 }
            .map { $0.0 }
        //TODO: error handling
        self.error = errorRouter.error
            .map { $0.localizedDescription }
    }
    
    private let viewDidLoadProperty = PublishRelay<Empty>()
    func viewDidLoad() {
        viewDidLoadProperty.accept(Empty())
    }
    
    private let selectedAnnotation = PublishRelay<PointAnnotation>()
    func didSelectAnnotation(_ annotation: PointAnnotation) {
        selectedAnnotation.accept(annotation)
    }
    
    private let shouldTrackLocationProperty = PublishRelay<Bool>()
    func shouldTrackLocation(_ trackingEnabled: Bool) {
        shouldTrackLocationProperty.accept(trackingEnabled)
    }
    
    var customLocationProvider: Single<MapboxMaps.LocationProvider>!
    var initialCameraOptions: RxObservable<CameraOptions>!
    var mapAnnotations: RxObservable<PointAnnotations>!
    var isAuthorisedToUseLocation: RxObservable<Bool>!
    var didDisableLocationServices: RxObservable<Empty>!
    var promptToEnableLocation: RxObservable<UIAlertController>!
    var isEnRoute: RxObservable<Bool>!
    var routeHighlightsViewIsVisible: RxObservable<Bool>!
    var onboardingMessage: RxObservable<OnboardingMessageAndComment>!
    var destinationHighlights: RxObservable<Destination>!
    var routeHighlights: RxObservable<Route>!
    var routeHighlightsRefreshing: RxObservable<Bool>!
    var polyline: RxObservable<PolylineAnnotations>!
    var updatedCameraOptions: RxObservable<CameraOptions>!
    var isTrackingLocation: RxObservable<Bool>!
    var error: RxObservable<String>!
    
    var inputs: MapViewModelInputs { self }
    var outputs: MapViewModelOutputs { self }
    
}
