//
//  Map.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 01.12.2022.
//

import MapboxMaps
import RxSwift
import RxCocoa

protocol MapViewType: MapView {// изменить на UIView по завершению настройки
    var bindablePointAnnotations: Binder<PointAnnotations> { get }
    var bindablePolylineAnnotations: Binder<PolylineAnnotations> { get }
    var didDetectTappedAnnotation: ControlEvent<PointAnnotation> { get }
    func overrideLocationProvider(withCustomLocationProvider provider: LocationProvider)
    /// an array of PointAnnotations
    typealias PointAnnotations = [PointAnnotation]
    /// an array of PolylineAnnotations
    typealias PolylineAnnotations = [PolylineAnnotation]
}

final class Map: MapView, MapViewType {
        
    private lazy var pointAnnotationManager: PointAnnotationManager = {
        annotations.makePointAnnotationManager()
    }()
    
    private lazy var polylineAnnotationManager: PolylineAnnotationManager = {
        let polylineAnnotationManager = annotations.makePolylineAnnotationManager()
        polylineAnnotationManager.lineCap = .round
        return polylineAnnotationManager
    }()
    
    var bindablePointAnnotations: Binder<PointAnnotations> {
        pointAnnotationManager.rx.annotations
    }
    
    var bindablePolylineAnnotations: Binder<PolylineAnnotations> {
        polylineAnnotationManager.rx.annotations
    }
    
    var didDetectTappedAnnotation: ControlEvent<PointAnnotation> {
        pointAnnotationManager.rx.didDetectTappedAnnotation
    }
    
    func overrideLocationProvider(withCustomLocationProvider provider: LocationProvider) {
        location.overrideLocationProvider(with: provider)
    }
    
    init(frame: CGRect) {
        let initOptions = MapInitOptions(resourceOptions: MapBoxConstants.resourceOptions,
                                          cameraOptions: MapBoxConstants.cameraOptions)
        super.init(frame: frame, mapInitOptions: initOptions)
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // configuring a 2-dimensional puck with heading indicator
        let puckConfiguration = Puck2DConfiguration.makeDefault(showBearing: true)
        location.options.puckType = .puck2D(puckConfiguration)
        location.options.activityType = .fitness // implies walking activities
    }
    
    @available(iOSApplicationExtension, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

