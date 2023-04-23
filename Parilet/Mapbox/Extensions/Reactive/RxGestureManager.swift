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
    
    fileprivate let mapViewDidBeginPanning = PublishSubject<()>()
    fileprivate let mapViewDidBeginPinching = PublishSubject<()>()
    
    init(parentObject: GestureManager) {
        super.init(parentObject: parentObject,
                   delegateProxy: RxGestureManagerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { RxGestureManagerDelegateProxy(parentObject: $0) }
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didBegin gestureType: MapboxMaps.GestureType) {
        switch gestureType {
        case .pan: mapViewDidBeginPanning.onNext(())
        case .pinch: mapViewDidBeginPinching.onNext(())
        default: return
        }
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEnd gestureType: MapboxMaps.GestureType, willAnimate: Bool) {
        // empty
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEndAnimatingFor gestureType: MapboxMaps.GestureType) {
        // empty
    }
    
}

extension Reactive where Base: GestureManager {
    fileprivate var delegate: RxGestureManagerDelegateProxy {
        RxGestureManagerDelegateProxy.proxy(for: base)
    }
    var mapViewDidBeginPanning: ControlEvent<()> {
        ControlEvent(events: delegate.mapViewDidBeginPanning)
    }
    var mapViewDidBeginPinching: ControlEvent<()> {
        ControlEvent(events: delegate.mapViewDidBeginPinching)
    }
}
