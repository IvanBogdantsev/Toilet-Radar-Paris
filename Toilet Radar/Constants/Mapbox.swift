//
//  MapBox.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 23.12.2022.
//

import MapboxMaps
import CoreLocation

enum MapBoxConstants {
    static let accessToken = ""
    static let imageName = "red_pin"
    static let resourceOptions: ResourceOptions = {
        ResourceOptions(accessToken: Self.accessToken)
    }()
    static let paris: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 48.8566,
                                                                      longitude: 2.3522)
    static let cameraLaunchOptions: CameraOptions = {
        CameraOptions(center: Self.paris, zoom: 10)
    }()
}

enum UserInfo {
    static let accesPmr = "accesPmr"
    static let type = "type"
    static let adresse = "adresse"
    static let arrondissement = "arrondissement"
    static let horaire = "horaire"
}
