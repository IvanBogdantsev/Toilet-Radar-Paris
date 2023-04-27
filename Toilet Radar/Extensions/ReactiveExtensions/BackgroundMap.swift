//
//  BackgroundMap.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 02.03.2023.
//

import RxSwift
import Dispatch

extension ObservableType {
    func backgroundMap<Result>(qos: DispatchQoS, _ transform: @escaping (Element) throws -> Result) -> Observable<Result> {
        return self
            .observe(on: SerialDispatchQueueScheduler(qos: qos))
            .map(transform)
    }
}

extension ObservableType {
    func backgroundCompactMap<Result>(qos: DispatchQoS, _ transform: @escaping (Element) throws -> Result?) -> Observable<Result> {
        return self
            .observe(on: SerialDispatchQueueScheduler(qos: qos))
            .compactMap(transform)
    }
}
