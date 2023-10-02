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
import StoreKit

final class MapViewController: UIViewController {
    
    private let mapSceneView = MapSceneView()
    private let viewModel: MapViewModelType = MapViewModel()
    private let bottomBanner = BottomBannerViewController()
    private let disposeBag = DisposeBag()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func loadView() {
        view = mapSceneView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelInputs()
        bindViewModelOutputs()
        viewModel.inputs.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        embed(bottomBanner, in: mapSceneView)
        mapSceneView.didReceiveBottomBannerView(bottomBanner.view)
    }
    
    private func bindViewModelInputs() {        
        mapSceneView.didDetectTappedAnnotation
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.inputs.didSelectAnnotation($0) })
            .disposed(by: disposeBag)
        
        mapSceneView.rxTapShowLocationButton
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.inputs.shouldTrackLocation(true) })
            .disposed(by: disposeBag)
        
        mapSceneView.rxMapGestures.mapViewDidBeginPanning
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.inputs.shouldTrackLocation(false) })
            .disposed(by: disposeBag)
        
        mapSceneView.rxMapGestures.mapViewDidBeginPinching
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.inputs.shouldTrackLocation(false) })
            .disposed(by: disposeBag)
        
        mapSceneView.rateThisAppButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                guard let scene = UIApplication.shared.connectedScenes.first(
                    where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
                SKStoreReviewController.requestReview(in: scene)
                self?.viewModel.inputs.didTapRateThisAppButton()
                self?.mapSceneView.rateThisAppButton.fade(duration: 0.8)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModelOutputs() {
        viewModel.outputs.customLocationProvider
            .subscribe(onSuccess: { [weak self] in
                guard let self = self else { return }
                self.mapSceneView.overrideMapLocationProvider(withCustom: $0) })
            .disposed(by: disposeBag)
        
        viewModel.outputs.initialCameraOptions
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.mapSceneView.setCameraOptions($0, duration: 0) })
            .disposed(by: disposeBag)
        
        viewModel.outputs.mapAnnotations.asDriver(onErrorDriveWith: .empty())
            .drive(mapSceneView.bindablePointAnnotations)
            .disposed(by: disposeBag)
        
        viewModel.outputs.isAuthorisedToUseLocation.asDriver(onErrorDriveWith: .empty())
            .drive(mapSceneView.locationButtonLocationDisabled)
            .disposed(by: disposeBag)
        
        viewModel.outputs.didDisableLocationServices
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.mapSceneView.clearPolylines() })
            .disposed(by: disposeBag)
        
        viewModel.outputs.promptToEnableLocation
            .observe(on: MainScheduler.instance) // observe for ui
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.present($0, animated: true) })
            .disposed(by: disposeBag)
        
        viewModel.outputs.isEnRoute.asDriver(onErrorDriveWith: .empty())
            .drive(bottomBanner.rx.isExpandable)
            .disposed(by: disposeBag)
        
        viewModel.outputs.routeHighlightsViewIsVisible.asDriver(onErrorDriveWith: .empty())
            .drive(bottomBanner.rx.routeHighlightsViewIsVisible)
            .disposed(by: disposeBag)
        
        viewModel.outputs.onboardingMessage
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.bottomBanner.setOnboardingMessage(message: $0) })
            .disposed(by: disposeBag)
        
        viewModel.outputs.routeHighlightsRefreshing.asDriver(onErrorDriveWith: .empty())
            .drive(bottomBanner.rx.routeHighlightsRefreshing)
            .disposed(by: disposeBag)
        
        viewModel.outputs.destinationHighlights
            .subscribe ( onNext: { [weak self] in
                guard let self = self else { return }
                self.bottomBanner.refreshDestination(with: $0) })
            .disposed(by: disposeBag)
        
        viewModel.outputs.routeHighlights
            .subscribe ( onNext: { [weak self] in
                guard let self = self else { return }
                self.bottomBanner.refreshRoute(with: $0) })
            .disposed(by: disposeBag)
        
        viewModel.outputs.polyline.asDriver(onErrorDriveWith: .empty())
            .drive(mapSceneView.bindablePolylineAnnotations)
            .disposed(by: disposeBag)
        
        viewModel.outputs.updatedCameraOptions
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.mapSceneView.setCameraOptions($0, duration: 1) })
            .disposed(by: disposeBag)
        
        viewModel.outputs.isTrackingLocation
            .bind(to: mapSceneView.isLocationButtonInTrackingMode)
            .disposed(by: disposeBag)
        
        viewModel.outputs.error.asDriver(onErrorDriveWith: .empty())
            .drive { print($0) }
            .disposed(by: disposeBag)
        
        viewModel.outputs.rateAppButtonIsHidden.asDriver(onErrorJustReturn: false)
            .drive(mapSceneView.rateThisAppButton.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
}
