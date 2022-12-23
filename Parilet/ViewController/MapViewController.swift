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
    private let viewModel: MapViewModelType = MapViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMapView()
        setUpBindings()
        viewModel.viewDidLoad()
    }

    private func setUpMapView() {
        mapView = Map(frame: view.bounds)
        view.addSubview(mapView)
    }
    
    private func setUpBindings() {
        viewModel.pointAnnotations
            .drive(mapView.bindableAnnotations)
            .disposed(by: disposeBag)
        
        mapView.didDetectTappedAnnotations
            .subscribe {
                print($0)
            }
            .disposed(by: disposeBag)
    }
    
}
