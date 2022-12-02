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

class MapViewController: UIViewController {
    
    private var mapView: Map!
    private let viewModel: MapViewModelProtocol = MapViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpMapView()
        setUpBindings()
    }

    private func setUpMapView() {
        mapView = Map(frame: view.bounds)
        self.view.addSubview(mapView)
    }

    private func setUpBindings() {
        viewModel.pointAnnotations
            .drive(mapView.bindableAnnotations)
            .disposed(by: disposeBag)
        
        mapView.rxAnnotationsDelegate.didDetectTappedAnnotations
            .subscribe {
                print($0)
            }
            .disposed(by: disposeBag)
        
        viewModel.viewDidLoad()
    }
    
}
