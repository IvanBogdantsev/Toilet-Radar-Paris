//
// ErrorRouter.swift
// Parilet
//
// Created by Daniel Tartgaglia on 19 Dec 2020.
// Copyright © 2023 Daniel Tartaglia. MIT License.
//
// Credit: https://github.com/danielt1263

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    /**
     Absorbs errors and routes them to the error router instead. If the source emits an error, this operator will
     emit a completed event and the error router will emit the error as a next event.
     - Parameter errorRouter: The error router that will accept the error.
     - Returns: The source observable's events with an error event converted to a completed event.
     */
    public func rerouteError(_ errorRouter: ErrorRouter) -> Observable<Element> {
        errorRouter.rerouteError(self)
    }
}

public final class ErrorRouter {
    
    public let error: Observable<Error>
    private let subject = PublishSubject<Error>()
    private let lock = NSRecursiveLock()
    
    public init() {
        error = subject.asObservable()
    }
    
    deinit {
        lock.lock()
        subject.onCompleted()
        lock.unlock()
    }
    
    func routeError(_ error: Error) {
        lock.lock()
        subject.onNext(error)
        lock.unlock()
    }
    
    fileprivate func rerouteError<O>(_ source: O) -> Observable<O.Element> where O: ObservableConvertibleType {
        source.asObservable()
            .observe(on: MainScheduler.instance)
            .catch { [self] error in
                self.routeError(error)
                return .empty()
            }
    }
    
}
