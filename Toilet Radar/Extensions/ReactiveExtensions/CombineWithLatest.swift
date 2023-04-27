//
//  CombineWithLatest.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 28.03.2023.
//

import RxSwift

extension ObservableType {
    func combineWithLatest<O: ObservableType>(_ other: O) -> Observable<(Element, O.Element)> {
        return Observable.combineLatest(self, other)
    }
}
