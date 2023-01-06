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
    typealias PointAnnotations = [PointAnnotation]
    typealias PolylineAnnotations = [PolylineAnnotation]

    var bindablePointAnnotations: Binder<PointAnnotations> { get }
    var bindablePolylineAnnotations: Binder<PolylineAnnotations> { get }
    var didDetectTappedAnnotation: ControlEvent<PointAnnotation> { get }
}

final class Map: MapView, MapViewType {
        
    private lazy var pointAnnotationManager: PointAnnotationManager = {
        annotations.makePointAnnotationManager()
    }()
    
    private lazy var polylineAnnotationManager: PolylineAnnotationManager = {
        annotations.makePolylineAnnotationManager()
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

