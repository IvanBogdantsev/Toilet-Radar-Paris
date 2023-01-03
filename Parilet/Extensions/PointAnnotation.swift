//
//  PointAnnotation.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 27.11.2022.
//

import MapboxMaps

extension PointAnnotation {
    init(withRecord record: Record) {
        let latitude = record.fields.geoPoint2D.first ?? Double()
        let longitude = record.fields.geoPoint2D.last ?? Double()
        self.init(id: record.recordid ?? "",
                  coordinate: CLLocationCoordinate2D(latitude: latitude,
                                                     longitude: longitude))
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
