//
//  Point.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 22.11.2022.
//

import Foundation

// MARK: - Dataset
struct Dataset: Codable {
    let nhits: Int
    let records: [Record]
}

// MARK: - Record
struct Record: Codable {
    let recordid: String
    let fields: Fields
    let recordTimestamp: String

    enum CodingKeys: String, CodingKey {
        case recordid, fields
        case recordTimestamp = "record_timestamp"
    }
}

// MARK: - Fields
struct Fields: Codable {
    let accesPmr: String?
    let type: String
    let geoPoint2D: [Double]
    let adresse: String
    let arrondissement, horaire: String?

    enum CodingKeys: String, CodingKey {
        case accesPmr = "acces_pmr"
        case type
        case geoPoint2D = "geo_point_2d"
        case horaire, adresse, arrondissement
    }
}
