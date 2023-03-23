//
//  Race.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 22.03.2023.
//

import RxSwift

extension ObservableType {
    func race(_ outer: Observable<Element>) -> Observable<Element> {
        return Observable.merge(self.asObservable(), outer)
    }
}
