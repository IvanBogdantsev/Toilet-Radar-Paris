//
//  ViewController.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 21.11.2022.
//

import MapboxMaps
import RxSwift
import RxCocoa
import UIKit

final class MapViewController: UIViewController {
    
    private var mapView: MapViewType!
    private var viewModel: MapViewModel!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMapView()
        setUpViewModel()
        bindViewModelInputs()
        bindViewModelOutputs()
    }

    private func setUpMapView() {
        mapView = Map(frame: view.bounds)
        view.addSubview(mapView)
    }
    
    private func setUpViewModel() {
        viewModel = MapViewModel(location: mapView.location)
    }
    
    private func bindViewModelInputs() {
        mapView.didDetectTappedAnnotations
            .subscribe(onNext: {
                self.viewModel.input.annotationPickedByUser.accept($0)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModelOutputs() {
        viewModel.output.mapAnnotations
            .drive(mapView.bindableAnnotations)
            .disposed(by: disposeBag)
        
        viewModel.output.route
            .drive()
            .disposed(by: disposeBag)
    }

}
