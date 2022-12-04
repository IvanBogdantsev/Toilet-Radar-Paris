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
    
    typealias Annotations = [PointAnnotation]
    
    var pointAnnotations: Driver<Annotations> {
        return annotations
            .asDriver(onErrorJustReturn: [])
            .skip(1)
    }
    private let annotations = BehaviorRelay<Annotations>(value: [])
    private let disposeBag = DisposeBag()

    func viewDidLoad() {
        APIClient<Dataset>.getDataset()
            .map { dataset in
                self.annotationsFrom(dataset.records)
            }
            .subscribe( onSuccess: { dataset in
                self.annotations.accept(dataset)
            },
            onFailure: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }

}

private extension MapViewModel {
    func annotationsFrom(_ records: [Record]) -> Annotations {
        var objs: Annotations = []
        records.forEach { record in
            var pa = PointAnnotation.init(with: record)
            pa.image = .init(image: UIImage.pin, name: "red_pin")
            pa.iconAnchor = .bottom
            objs.append(pa)
        }
        return objs
    }
}
