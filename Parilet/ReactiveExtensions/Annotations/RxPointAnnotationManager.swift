//
//  AnnotationManager.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 25.11.2022.
//

import MapboxMaps
import RxSwift
import RxCocoa

extension PointAnnotationManager: ReactiveCompatible {}

extension PointAnnotationManager: HasDelegate {
    public typealias Delegate = AnnotationInteractionDelegate
}

final class RxAnnotationManagerDelegateProxy: DelegateProxy<PointAnnotationManager, AnnotationInteractionDelegate>, DelegateProxyType, AnnotationInteractionDelegate {
    
    internal func annotationManager(_ manager: MapboxMaps.AnnotationManager, didDetectTappedAnnotations annotations: [MapboxMaps.Annotation]) {
        guard let pointAnnotation = annotations.first as? PointAnnotation else { return }
        didDetectTappedAnnotations.onNext(pointAnnotation)
    }
    
    fileprivate let didDetectTappedAnnotations = PublishSubject<PointAnnotation>()
    
    init(parentObject: PointAnnotationManager) {
        super.init(parentObject: parentObject,
                   delegateProxy: RxAnnotationManagerDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxAnnotationManagerDelegateProxy(parentObject: $0) }
    }
    
}

extension Reactive where Base: PointAnnotationManager {
    fileprivate var delegate: RxAnnotationManagerDelegateProxy {
        return RxAnnotationManagerDelegateProxy.proxy(for: base)
    }
    var didDetectTappedAnnotation: ControlEvent<PointAnnotation> {
        return ControlEvent(events: delegate.didDetectTappedAnnotations)
    }
}
