//
//  ViewController.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 21.11.2022.
//

import UIKit
import MapboxMaps
import RxSwift
import Alamofire
 
class ViewController: UIViewController {
    
    private var mapView: MapView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMapView()
    }
    
    private func setUpMapView() {
        let myResourceOptions = ResourceOptions(accessToken: MapBoxConstants.accesToken)
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)
    }
        
}
