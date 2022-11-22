//
//  Point.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 22.11.2022.
//

import Foundation

// MARK: - Welcome
struct Point: Codable {
    let nhits: Int
    let parameters: Parameters
    let records: [Record]
}

// MARK: - Parameters
struct Parameters: Codable {
    let dataset: String
    let rows, start: Int
    let format, timezone: String
}

// MARK: - Record
struct Record: Codable {
    let datasetid, recordid: String
    let fields: Fields
    let geometry: Geometry
    let recordTimestamp: String

    enum CodingKeys: String, CodingKey {
        case datasetid, recordid, fields, geometry
        case recordTimestamp = "record_timestamp"
    }
}

// MARK: - Fields
struct Fields: Codable {
    let accesPmr: String?
    let geoShape: GeoShape
    let type: String
    let geoPoint2D: [Double]
    let adresse: String
    let arrondissement, horaire: String?

    enum CodingKeys: String, CodingKey {
        case accesPmr = "acces_pmr"
        case geoShape = "geo_shape"
        case type
        case geoPoint2D = "geo_point_2d"
        case horaire, adresse, arrondissement
    }
}

// MARK: - GeoShape
struct GeoShape: Codable {
    let coordinates: [[Double]]
    let type: String
}

// MARK: - Geometry
struct Geometry: Codable {
    let type: String
    let coordinates: [Double]
}
