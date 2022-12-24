//
//  PointAnnotation.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 27.11.2022.
//

import MapboxMaps

extension PointAnnotation {
    init(withRecord record: Record) {
        let lat = record.fields.geoPoint2D.first ?? Double()
        let lon = record.fields.geoPoint2D.last ?? Double()
        self.init(id: record.recordid ?? "",
                  coordinate: CLLocationCoordinate2D(latitude: lat,
                                                     longitude: lon))
        self.userInfo = [UserInfo.accesPmr.rawValue : record.fields.accesPmr ?? "??",
                         UserInfo.horaire.rawValue : record.fields.horaire ?? "??",
                         UserInfo.arrondissement.rawValue : record.fields.arrondissement ?? "??",
                         UserInfo.type.rawValue : record.fields.type ?? "??",
                         UserInfo.adresse.rawValue : record.fields.adresse ?? "??"]
        self.image = .init(image: UIImage.pin, name: MapBoxConstants.imageName)
        self.iconImage = MapBoxConstants.imageName
    }
}
