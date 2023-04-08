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
    
    private let mapSceneView: MapViewSceneType = MapSceneView()
    private let viewModel: MapViewModelType = MapViewModel()
    private let bottomBanner = BottomBannerViewController()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = mapSceneView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelInputs()
        bindViewModelOutputs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        embed(bottomBanner, in: mapSceneView)
        mapSceneView.didReceiveBottomBannerView(bottomBanner.view)
    }
    
    private func bindViewModelInputs() {
        mapSceneView.didDetectTappedAnnotation
            .subscribe(onNext: { self.viewModel.inputs.didSelectAnnotation($0) })
            .disposed(by: disposeBag)
        
        mapSceneView.rxTapShowLocationButton
            .subscribe(onNext: { self.viewModel.inputs.shouldTrackUserLocation(true) })
            .disposed(by: disposeBag)
        
        mapSceneView.rxMapGestures.mapViewDidBeginPanning
            .subscribe(onNext: { self.viewModel.inputs.shouldTrackUserLocation(false) })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModelOutputs() {
        viewModel.outputs.customLocationProvider
            .subscribe(onSuccess: { self.mapSceneView.overrideMapLocationProvider(withCustom: $0) })
            .disposed(by: disposeBag)
        
        viewModel.outputs.mapAnnotations
            .asDriver(onErrorDriveWith: .empty())
            .drive(mapSceneView.bindablePointAnnotations)
            .disposed(by: disposeBag)
        
        viewModel.outputs.destinationHighlights
            .subscribe ( onNext: { self.bottomBanner.refreshDestination(with: $0) })
            .disposed(by: disposeBag)
        
        viewModel.outputs.routeHighlights
            .subscribe ( onNext: { self.bottomBanner.refreshRoute(with: $0) })
            .disposed(by: disposeBag)
        
        viewModel.outputs.polyline
            .asDriver(onErrorDriveWith: .empty())
            .drive(mapSceneView.bindablePolylineAnnotations)
            .disposed(by: disposeBag)
        
        viewModel.outputs.updatedCameraPosition
            .subscribe(onNext: { self.mapSceneView.setCameraPosition(to: $0) })
            .disposed(by: disposeBag)
        
        viewModel.outputs.isTrackingLocation
            .bind(to: mapSceneView.isLocationButtonInTrackingMode)
            .disposed(by: disposeBag)
        
        viewModel.outputs.error
            .asDriver(onErrorDriveWith: .empty())
            .drive { print($0) }
            .disposed(by: disposeBag)
    }
    
}
