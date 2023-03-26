//
//  PointAnnotation.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 27.11.2022.
//

import MapboxMaps
import MapKit

extension PointAnnotation {
    /// Creates an instance of PointAnnotation.
    ///  - Parameter record: The most basic information about an object on the map returned by the Sanisette API.
    ///  - Returns: An instance of PointAnnotation with a defined coordinate, image and user info.
    init(withRecord record: Record) {
        let latitude = record.fields.geoPoint2D.first ?? Double()
        let longitude = record.fields.geoPoint2D.last ?? Double()
        let point = Point(LocationCoordinate2D(latitude: latitude, longitude: longitude))
        self.init(id: record.recordid ?? "", point: point)
        self.userInfo = [UserInfo.accesPmr.rawValue : record.fields.accesPmr ?? "??",
                         UserInfo.horaire.rawValue : record.fields.horaire ?? "??",
                         UserInfo.arrondissement.rawValue : record.fields.arrondissement ?? "??",
                         UserInfo.type.rawValue : record.fields.type ?? "??",
                         UserInfo.adresse.rawValue : record.fields.adresse ?? "??"]
        self.image = .init(image: UIImage.pin, name: MapBoxConstants.imageName)
        self.iconImage = MapBoxConstants.imageName
    }
}

extension PointAnnotation {
    var coordinate: LocationCoordinate2D {
        point.coordinates
    }
}

extension PointAnnotation {
    var userInfoUnwrapped: Dictionary<String, Any> {
        userInfo ?? [:]
    }
}
