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
import SnapKit

protocol MapViewSceneType: UIView {
    var bindablePointAnnotations: Binder<PointAnnotations> { get }
    var bindablePolylineAnnotations: Binder<PolylineAnnotations> { get }
    var didDetectTappedAnnotation: ControlEvent<PointAnnotation> { get }
    var rxTapShowLocationButton: ControlEvent<Void> { get }
    var rxMapGestures: Reactive<GestureManager> { get }
    var isLocationButtonInTrackingMode: Binder<Bool> { get }
    var locationButtonLocationDisabled: Binder<Bool> { get }
    func overrideMapLocationProvider(withCustom provider: LocationProvider)
    func didReceiveBottomBannerView(_ view: UIView)
    func setCameraOptions(_ options: CameraOptions, duration: CGFloat)
    func clearPolylines()
    /// an array of PointAnnotations
    typealias PointAnnotations = [PointAnnotation]
    /// an array of PolylineAnnotations
    typealias PolylineAnnotations = [PolylineAnnotation]
}

final class MapSceneView: UIView {
    
    private let mapView: Map
    private let showMyLocationButton = ShowMyLocationButton()
    let rateThisAppButton = UIButton()
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
        layout()
        setStyle()
    }
    
    private func layout() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mapView)
        mapView.pinToEdges(of: self)
        
        addSubview(rateThisAppButton)
        rateThisAppButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).inset(60)
            $0.right.equalToSuperview().inset(8)
            $0.left.greaterThanOrEqualToSuperview()
        }
    }
    
    private func setStyle() {
        rateThisAppButton.backgroundColor = .secondarySystemBackground
        rateThisAppButton.layer.cornerRadius = 12
        rateThisAppButton.setImage(UIImage.star, for: .normal)
        rateThisAppButton.tintColor = .prlYellow
        
        rateThisAppButton.titleLabel?.numberOfLines = 0
        rateThisAppButton.setTitle(Strings.am_i_a_good_app, for: .normal)
        rateThisAppButton.setTitleColor(.label, for: .normal)
        
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        configuration.imagePadding = 5
        rateThisAppButton.configuration = configuration

        rateThisAppButton.layer.shadowColor = UIColor.black.cgColor
        rateThisAppButton.layer.shadowOpacity = 0.2
        rateThisAppButton.layer.shadowRadius = 1
        rateThisAppButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        rateThisAppButton.layer.masksToBounds = false
        
        rateThisAppButton.alpha = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            self.rateThisAppButton.appear(duration: 0.5)
        }
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
    
    var rxTapShowLocationButton: ControlEvent<Void> {
        showMyLocationButton.rx.tap
    }
    
    var rxMapGestures: Reactive<GestureManager> {
        mapView.gestures.rx
    }
    
    var isLocationButtonInTrackingMode: Binder<Bool> {
        showMyLocationButton.rx.isInLocationTrackingMode
    }
    
    var locationButtonLocationDisabled: Binder<Bool> {
        showMyLocationButton.rx.shouldShowUnknownLocationIcon
    }
    
    func overrideMapLocationProvider(withCustom provider: LocationProvider) {
        mapView.location.overrideLocationProvider(with: provider)
    }
    
    func setCameraOptions(_ options: CameraOptions, duration: CGFloat) {
        mapView.camera.ease(to: options, duration: duration)
    }
    
    func didReceiveBottomBannerView(_ view: UIView) {
        addSubview(showMyLocationButton)
        showMyLocationButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        showMyLocationButton.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -20).isActive = true
    }
    
    func clearPolylines() {
        polylineAnnotationManager.annotations = []
    }
}
