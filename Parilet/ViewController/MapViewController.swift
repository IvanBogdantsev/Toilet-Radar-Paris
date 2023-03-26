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
    private var viewModel: MapViewModelType = MapViewModel()
    private let bottomBanner = BottomBannerViewController()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapView()
        bindViewModelInputs()
        bindViewModelOutputs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        embed(bottomBanner, in: view)
    }
    
    private func setUpMapView() {
        mapView = Map(frame: view.bounds)
        view.addSubview(mapView)
    }
    
    private func bindViewModelInputs() {
        mapView.didDetectTappedAnnotation
            .subscribe(onNext: { self.viewModel.inputs.didSelectAnnotation($0) })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModelOutputs() {
        viewModel.outputs.customLocationProvider
            .subscribe(onSuccess: { self.mapView.overrideLocationProvider(withCustomLocationProvider: $0) })
            .disposed(by: disposeBag)
        
        viewModel.outputs.mapAnnotations
            .asDriver(onErrorDriveWith: .empty())
            .drive(mapView.bindablePointAnnotations)
            .disposed(by: disposeBag)
        
        viewModel.outputs.destinationHighlights
            .subscribe { self.bottomBanner.refreshDestination(with: $0) }
            .disposed(by: disposeBag)
        
        viewModel.outputs.routeHighlights
            .subscribe { self.bottomBanner.refreshRoute(with: $0) }
            .disposed(by: disposeBag)
        
        viewModel.outputs.polyline
            .asDriver(onErrorDriveWith: .empty())
            .drive(mapView.bindablePolylineAnnotations)
            .disposed(by: disposeBag)
        
        viewModel.outputs.error
            .asDriver(onErrorDriveWith: .empty())
            .drive { print($0) }
            .disposed(by: disposeBag)
    }
    
}
