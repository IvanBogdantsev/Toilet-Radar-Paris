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
        didDetectTappedAnnotations.onNext(annotations[0])
    }
    
    fileprivate let didDetectTappedAnnotations =
    PublishSubject<Annotation>()
    
    init(parentObject: PointAnnotationManager) {
            super.init(
                parentObject: parentObject,
                delegateProxy: RxAnnotationManagerDelegateProxy.self
            )
        }
    
    public static func registerKnownImplementations() {
            self.register { RxAnnotationManagerDelegateProxy(parentObject: $0) }
        }
    
}

extension Reactive where Base: PointAnnotationManager {
    var delegate: RxAnnotationManagerDelegateProxy {
        return RxAnnotationManagerDelegateProxy.proxy(for: base)
    }
    var didDetectTappedAnnotations: ControlEvent<Annotation> {
        return ControlEvent(events: delegate.didDetectTappedAnnotations)
    }
}


