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
    private let viewModel: MapViewModelType = MapViewModel()
    private let bottomBanner = BottomBannerViewController()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        bindInputs()
        bindOutputs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        embed(bottomBanner, in: view)
    }
    
    private func setupMapView() {
        mapView = Map(frame: view.bounds)
        view.addSubview(mapView)
    }
    
    private func bindInputs() {
        mapView.didDetectTappedAnnotation
            .subscribe(onNext: { self.viewModel.inputs.didSelectAnnotation($0) })
            .disposed(by: disposeBag)
    }
    
    private func bindOutputs() {
        viewModel.outputs.customLocationProvider
            .subscribe(onSuccess: { self.mapView.overrideLocationProvider(withCustomLocationProvider: $0) })
            .disposed(by: disposeBag)
        
        viewModel.outputs.mapAnnotations
            .asDriver(onErrorDriveWith: .empty())
            .drive(mapView.bindablePointAnnotations)
            .disposed(by: disposeBag)
        
        viewModel.outputs.destinationHighlights
            .subscribe ( onNext: { self.bottomBanner.refreshDestination(with: $0) })
            .disposed(by: disposeBag)
        
        viewModel.outputs.routeHighlights
            .subscribe ( onNext: { self.bottomBanner.refreshRoute(with: $0) })
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
