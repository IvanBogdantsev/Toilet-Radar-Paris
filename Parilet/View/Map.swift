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
    typealias Annotations = [PointAnnotation]

    var bindableAnnotations: Binder<Annotations> { get }
    var didDetectTappedAnnotations: ControlEvent<Annotation> { get }
}

final class Map: MapView, MapViewType {
        
    private lazy var annotationManager: PointAnnotationManager = {
        annotations.makePointAnnotationManager()
    }()
    
    var bindableAnnotations: Binder<Annotations> {
        annotationManager.rx.annotations
    }
    
    var didDetectTappedAnnotations: ControlEvent<Annotation> {
        annotationManager.rx.didDetectTappedAnnotations
    }
    
    init(frame: CGRect) {
        let initOptions = MapInitOptions(resourceOptions: MapBoxConstants.resourceOptions,
                                          cameraOptions: MapBoxConstants.cameraOptions)
        super.init(frame: frame, mapInitOptions: initOptions)
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // configuring a 2-dimensional puck with heading indicator
        let conf = Puck2DConfiguration.makeDefault(showBearing: true)
        location.options.puckType = .puck2D(conf)
        location.options.activityType = .fitness // implies walking activities
    }
    
    @available(iOSApplicationExtension, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

