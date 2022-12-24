//
//  ViewController.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 21.11.2022.
//

import UIKit
import MapboxMaps
import RxSwift
import RxCocoa

final class MapViewController: UIViewController {
    
    private var mapView: MapViewProtocol!
    private var viewModel = MapViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMapView()
        bindViewModelOutputs()
        bindViewModelInputs()
    }

    private func setUpMapView() {
        mapView = Map(frame: view.bounds)
        view.addSubview(mapView)
    }
    
    private func bindViewModelOutputs() {
        viewModel.output.mapAnnotations
            .drive(mapView.bindableAnnotations)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModelInputs() {
        
    }
    
}
