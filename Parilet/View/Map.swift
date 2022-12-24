//
//  Map.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 01.12.2022.
//

import MapboxMaps
import RxSwift
import RxCocoa

protocol MapViewProtocol: UIView {
    typealias Annotations = [PointAnnotation]

    var bindableAnnotations: Binder<Annotations> { get }
    var didDetectTappedAnnotations: ControlEvent<Annotation> { get }
}

final class Map: MapView, MapViewProtocol {
        
    private lazy var annotationManager: PointAnnotationManager = {
       self.annotations.makePointAnnotationManager()
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
    }
    
    @available(iOSApplicationExtension, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

