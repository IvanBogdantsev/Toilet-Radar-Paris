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
    lazy private var disposeBag: DisposeBag = {
        return DisposeBag()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpMapView()
        setUpAnnotationManager()
        setUpBindings()
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

    }

}

/*
 Observable.just([PointAnnotation( point: Point(LocationCoordinate2D(latitude: 48.862221666357485,
 longitude: 2.344254327997302))), PointAnnotation( point: Point(LocationCoordinate2D(latitude:
 48.862221666357485, longitude: 2.344254327997302)))]).bind(to: annotationManager.rx.annotations)
 */
