//
//  GestureManager.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 28.03.2023.
//

import MapboxMaps
import RxSwift
import RxCocoa

extension GestureManager: ReactiveCompatible {}

extension GestureManager: HasDelegate {
    public typealias Delegate = GestureManagerDelegate
}

final class RxGestureManagerDelegateProxy: DelegateProxy<GestureManager, GestureManagerDelegate>, DelegateProxyType, GestureManagerDelegate {
    
    fileprivate let mapViewDidBegingPanning = PublishSubject<()>()
    
    init(parentObject: GestureManager) {
        super.init(parentObject: parentObject,
                   delegateProxy: RxGestureManagerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { RxGestureManagerDelegateProxy(parentObject: $0) }
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didBegin gestureType: MapboxMaps.GestureType) {
        switch gestureType {
        case .pan: mapViewDidBegingPanning.onNext(())
        default: return
        }
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEnd gestureType: MapboxMaps.GestureType, willAnimate: Bool) {
        // empty implementation
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEndAnimatingFor gestureType: MapboxMaps.GestureType) {
        // empty implementation
    }
    
}

extension Reactive where Base: GestureManager {
    fileprivate var delegate: RxGestureManagerDelegateProxy {
        RxGestureManagerDelegateProxy.proxy(for: base)
    }
    var mapViewDidBeginPanning: ControlEvent<()> {
        ControlEvent(events: delegate.mapViewDidBegingPanning)
    }
}
