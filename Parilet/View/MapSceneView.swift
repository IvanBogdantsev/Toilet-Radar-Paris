//
//  MapSceneView.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 26.03.2023.
//

import UIKit
import RxSwift
import RxCocoa
import MapboxMaps

protocol MapViewSceneType: UIView {
    var bindablePointAnnotations: Binder<PointAnnotations> { get }
    var bindablePolylineAnnotations: Binder<PolylineAnnotations> { get }
    var didDetectTappedAnnotation: ControlEvent<PointAnnotation> { get }
    func overrideMapLocationProvider(withCustom provider: LocationProvider)
    func didReceiveBottomBannerView(_ view: UIView)
    /// an array of PointAnnotations
    typealias PointAnnotations = [PointAnnotation]
    /// an array of PolylineAnnotations
    typealias PolylineAnnotations = [PolylineAnnotation]
}

final class MapSceneView: UIView {
    
    private let mapView: Map
    private let showMyLocationButton = ShowMyLocationButton()
    private lazy var pointAnnotationManager: PointAnnotationManager = {
        mapView.annotations.makePointAnnotationManager()
    }()
    
    private lazy var polylineAnnotationManager: PolylineAnnotationManager = {
        let polylineAnnotationManager = mapView.annotations.makePolylineAnnotationManager()
        polylineAnnotationManager.lineCap = .round
        return polylineAnnotationManager
    }()
    
    init() {
        mapView = Map(frame: .zero)
        super.init(frame: .zero)
        setupMapView()
    }
    
    private func setupMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mapView)
        mapView.pinToEdges(of: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MapSceneView: MapViewSceneType {
    var bindablePointAnnotations: RxSwift.Binder<PointAnnotations> {
        pointAnnotationManager.rx.annotations
    }
    
    var bindablePolylineAnnotations: RxSwift.Binder<PolylineAnnotations> {
        polylineAnnotationManager.rx.annotations
    }
    
    var didDetectTappedAnnotation: RxCocoa.ControlEvent<PointAnnotation> {
        pointAnnotationManager.rx.didDetectTappedAnnotation
    }
    
    func overrideMapLocationProvider(withCustom provider: LocationProvider) {
        mapView.location.overrideLocationProvider(with: provider)
    }
    
    func didReceiveBottomBannerView(_ view: UIView) {
        addSubview(showMyLocationButton)
        showMyLocationButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        showMyLocationButton.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -20).isActive = true
    }
}
