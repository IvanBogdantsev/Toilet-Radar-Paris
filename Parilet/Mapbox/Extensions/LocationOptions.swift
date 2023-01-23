//
//  LocationsOptions.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 19.01.2023.
//

import MapboxMaps

extension LocationOptions {
    init(distanceFilter: CLLocationDistance,
         desiredAccuracy: CLLocationAccuracy,
         activityType: CLActivityType) {
        self.init()
        self.distanceFilter = distanceFilter
        self.desiredAccuracy = desiredAccuracy
        self.activityType = activityType
    }
}
