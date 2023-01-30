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

private protocol Parentable: AnyObject {
    func adopt(child: Childable)
}

extension Parentable where Self: UIViewController {
    fileprivate func adopt(child: Childable) {
        guard let child = child as? UIViewController else { return }
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
}

final class MapViewController: UIViewController, Parentable {
    
    private var mapView: MapViewType!
    private var viewModel = MapViewModel()
    private let disposeBag = DisposeBag()
    private let bottomSheetVC: Childable = BottomSheetViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapView()
        bindViewModelInputs()
        bindViewModelOutputs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adopt(child: bottomSheetVC)
    }
    
    private func setUpMapView() {
        mapView = Map(frame: view.bounds)
        view.addSubview(mapView)
    }
    
    private func bindViewModelInputs() {
        mapView.didDetectTappedAnnotation
            .subscribe(onNext: { annotationPickedByUser in
                self.viewModel.input.annotationPickedByUser.accept(annotationPickedByUser)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModelOutputs() {
        viewModel.output.customLocationProvider
            .subscribe(onSuccess: { locationProvider in
                self.mapView.overrideLocationProvider(withCustomLocationProvider: locationProvider)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.mapAnnotations
            .drive(mapView.bindablePointAnnotations)
            .disposed(by: disposeBag)
        
        viewModel.output.route
            .drive(mapView.bindablePolylineAnnotations)
            .disposed(by: disposeBag)
        
        viewModel.output.error
            .drive { print($0) }
            .disposed(by: disposeBag)
    }
    
}
