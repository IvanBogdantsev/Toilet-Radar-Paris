//
//  Map.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 01.12.2022.
//

import MapboxMaps
import RxSwift

final class Map: MapView {
    
    lazy var annotationManager: PointAnnotationManager = {
       self.annotations.makePointAnnotationManager()
    }()
    
    var bindableAnnotations: Binder<[PointAnnotation]> {
        annotationManager.rx.annotations
    }
    
    var rxAnnotationsDelegate: Reactive<PointAnnotationManager> {
        annotationManager.rx
    }
    
    init(frame: CGRect) {
        let myResourceOptions = ResourceOptions(accessToken: MapBoxConstants.accesToken)
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions)
        super.init(frame: frame, mapInitOptions: myMapInitOptions)
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @available(iOSApplicationExtension, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
