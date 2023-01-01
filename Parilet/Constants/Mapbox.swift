//
//  MapBox.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 23.12.2022.
//

import MapboxMaps

struct MapBoxConstants {
    static let accesToken = "pk.eyJ1IjoieXZhbmIiLCJhIjoiY2xhcXl6eTg5MDFrdzQwb3Z6OTAxeG9vcyJ9.f9bFprti9yDDWP1MigBL9Q"
    static let imageName = "red_pin"
    static let resourceOptions: ResourceOptions = {
        ResourceOptions(accessToken: Self.accesToken)
    }()
    static let cameraOptions: CameraOptions = {
        CameraOptions(center: CLLocationCoordinate2D(latitude: 48.8566,
                                                     longitude: 2.3522),
                                                     zoom: 10)
    }()
    
    init() {
        fatalError("\(String(describing: type(of: self))) cannot be constructed")
    }
}

enum UserInfo: String {
    case accesPmr, type, adresse, arrondissement, horaire
}
