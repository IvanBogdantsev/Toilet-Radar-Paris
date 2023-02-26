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
    private var viewModel = MapViewModel()
    private let disposeBag = DisposeBag()
    private let destinationBanner = BottomBannerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapView()
        bindViewModelInputs()
        bindViewModelOutputs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        embed(destinationBanner, in: view)
    }
    
    private func setUpMapView() {
        mapView = Map(frame: view.bounds)
        view.addSubview(mapView)
    }
    
    private func bindViewModelInputs() {
        mapView.didDetectTappedAnnotation
            .subscribe(onNext: { annotationPickedByUser in
                self.viewModel.input.annotationPickedByUser.accept(annotationPickedByUser)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModelOutputs() {
        viewModel.output.customLocationProvider
            .subscribe(onSuccess: { locationProvider in
                self.mapView.overrideLocationProvider(withCustomLocationProvider: locationProvider)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.mapAnnotations
            .asDriver(onErrorDriveWith: .empty())
            .drive(mapView.bindablePointAnnotations)
            .disposed(by: disposeBag)
        
        viewModel.output.route
            .asDriver(onErrorDriveWith: .empty())
            .drive(mapView.bindablePolylineAnnotations)
            .disposed(by: disposeBag)
        
        viewModel.output.error
            .asDriver(onErrorDriveWith: .empty())
            .drive { print($0) }
            .disposed(by: disposeBag)
    }
    
}
