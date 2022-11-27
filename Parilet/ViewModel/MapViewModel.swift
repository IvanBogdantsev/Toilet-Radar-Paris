//
//  MapViewModel.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 24.11.2022.
//

import RxSwift
import RxCocoa
import MapboxMaps

protocol MapViewModelProtocol {
    func viewDidLoad()
}

class MapViewModel: MapViewModelProtocol {
    
    var pointAnnotations: Driver<[PointAnnotation]> {
        return annotations
            .asDriver(onErrorJustReturn: [])
            .skip(1)
    }
    private let annotations = BehaviorRelay<[PointAnnotation]>(value: [])
    private let disposeBag = DisposeBag()

    func viewDidLoad() {
        APIClient<Dataset>.getDataset()
            .subscribe(onNext: { dataset in
                var objs: [PointAnnotation] = []
                dataset.records.forEach {
                    var pa = PointAnnotation(with: $0)
                    pa.image = .init(image: UIImage.pin, name: "red_pin")
                    pa.iconAnchor = .bottom
                    objs.append(pa)
                }
                self.annotations.accept(objs)
            })
            .disposed(by: disposeBag)
    }

}
