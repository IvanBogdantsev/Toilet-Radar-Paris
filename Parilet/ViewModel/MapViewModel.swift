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
    var pointAnnotations: Driver<[PointAnnotation]> { get }
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
            .map { dataset in
                var objs: [PointAnnotation] = []
                dataset.records.forEach { record in
                    var pa = PointAnnotation(with: record)
                    pa.image = .init(image: UIImage.pin, name: "red_pin")
                    pa.iconAnchor = .bottom
                    objs.append(pa)
                }
                return objs
            }
            .subscribe(onNext: { annotations in
                self.annotations.accept(annotations)
            })
            .disposed(by: disposeBag)
    }

}
