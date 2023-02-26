//
//  Destination.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 02.02.2023.
//

import Foundation
import MapboxDirections
import Turf

struct Destination {
    let prmAcces: String?
    let schedule: String?
    let district: String?
    let type: String?
    let address: String?
    let expectedTravelTime: TimeInterval?
    let distance: LocationDistance?
    
    init(destinationInfo: Dictionary<String, Any>, routeInfo: RouteResponse) {
        prmAcces = destinationInfo[UserInfo.accesPmr.rawValue] as? String
        schedule = destinationInfo[UserInfo.horaire.rawValue] as? String
        district = destinationInfo[UserInfo.arrondissement.rawValue] as? String
        type = destinationInfo[UserInfo.type.rawValue] as? String
        address = destinationInfo[UserInfo.adresse.rawValue] as? String
        expectedTravelTime = routeInfo.routes?.first?.expectedTravelTime
        distance = routeInfo.routes?.first?.distance
    }
}
