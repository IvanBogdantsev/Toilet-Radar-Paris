//
//  MapViewModel.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 24.11.2022.
//

import RxSwift
import RxCocoa
import MapboxMaps

protocol MapViewModelType {
    
    typealias Annotations = [PointAnnotation]
    typealias Records = [Record]
    
    func viewDidLoad()
    var pointAnnotations: Driver<Annotations> { get }
}

final class MapViewModel: MapViewModelType {
    
    private let apiClient = APIClient<SanisetteData>()
    private let annotations = BehaviorRelay<Annotations>(value: [])
    private let disposeBag = DisposeBag()
    
    var pointAnnotations: Driver<Annotations> {
        return annotations
            .asDriver(onErrorJustReturn: [])
            .skip(1)
    }

    func viewDidLoad() {
        apiClient.getData()
            .map { data in
                self.convertIntoAnnotations(from: data.records)
            }
            .subscribe( onSuccess: { annotations in
                self.annotations.accept(annotations)
            },
            onFailure: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }

}

private extension MapViewModel {
    func convertIntoAnnotations(from records: Records) -> Annotations {
        var objs: Annotations = []
        records.forEach { record in
            var pa = PointAnnotation.init(withRecord: record)
            pa.image = .init(image: UIImage.pin, name: "red_pin")
            objs.append(pa)
        }
        return objs
    }
}
