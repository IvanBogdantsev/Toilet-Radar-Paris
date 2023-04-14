//
//  AsEmpty.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 12.04.2023.
//

import RxSwift

extension ObservableType {
    func asEmpty() -> Observable<()> {
        self.map { _ in () }
    }
}
