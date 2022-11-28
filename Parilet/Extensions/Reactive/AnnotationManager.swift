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
/*
extension PointAnnotationManager: HasDelegate {
    public typealias Delegate = AnnotationInteractionDelegate
}

class RxMKMapViewDelegateProxy: DelegateProxy<PointAnnotationManager, AnnotationInteractionDelegate>, DelegateProxyType, AnnotationInteractionDelegate {
    
    func annotationManager(_ manager: MapboxMaps.AnnotationManager, didDetectTappedAnnotations annotations: [MapboxMaps.Annotation]) {
        
    }
    

    /// Typed parent object.
    public weak private(set) var manager: PointAnnotationManager?

    /// - parameter mapView: Parent object for delegate proxy.
    public init(mapView: ParentObject) {
        //self.mapView = mapView
        super.init(parentObject: mapView, delegateProxy: RxMKMapViewDelegateProxy.self)
    }
    static func registerKnownImplementations() {
        self.register { RxMKMapViewDelegateProxy(mapView: $0) }
    }
}

func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}

extension Reactive where Base: AnnotationManager {
    
    public var delegate: DelegateProxy<PointAnnotationManager, AnnotationInteractionDelegate> {
        return RxMKMapViewDelegateProxy.proxy(for: base as! RxMKMapViewDelegateProxy.ParentObject)
        }
    
    public var didSelectAnnotationView: ControlEvent<PointAnnotation> {
            let source = delegate
                .methodInvoked(#selector(AnnotationInteractionDelegate.mapView(_:didSelect:)))
                .map { a in
                    return try castOrThrow(PointAnnotation.self, a[1])
                }
            return ControlEvent(events: source)
        }
    
}
*/
