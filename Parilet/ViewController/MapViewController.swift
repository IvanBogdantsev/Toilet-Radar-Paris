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
    
    private let label: UILabel = {
       let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "FFF"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapView()
        setLabel()
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
            .subscribe(onNext: { selectedAnnotation in
                self.viewModel.inputs.didSelectAnnotation(selectedAnnotation)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModelOutputs() {
        viewModel.outputs.customLocationProvider
            .subscribe(onSuccess: { locationProvider in
                self.mapView.overrideLocationProvider(withCustomLocationProvider: locationProvider)
            })
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
        
        viewModel.outputs.distanceTraveld
            .subscribe { self.label.text = String($0) }
    }
    
}

extension MapViewController {
    
    func setLabel() {
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
}
