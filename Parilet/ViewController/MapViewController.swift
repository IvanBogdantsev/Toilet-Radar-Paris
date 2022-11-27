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

    private var mapView: MapView!
    private var annotationManager: PointAnnotationManager!
    private let viewModel = MapViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpMapView()
        setUpAnnotationManager()
        setUpBindings()
        viewModel.viewDidLoad()
    }

    private func setUpMapView() {
        let myResourceOptions = ResourceOptions(accessToken: MapBoxConstants.accesToken)
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)
    }

    private func setUpAnnotationManager() {
        annotationManager = mapView.annotations.makePointAnnotationManager()
    }

    private func setUpBindings() {
        viewModel.pointAnnotations
            .drive(annotationManager.rx.annotations)
            .disposed(by: disposeBag)
    }
}
