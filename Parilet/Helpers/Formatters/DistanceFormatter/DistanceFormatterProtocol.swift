//
//  DistanceFormatterProtocol.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 06.03.2023.
//

import MapKit

protocol DistanceFormatterProtocol: FormatterProtocol {
    var distanceFormatterOptions: DistanceFormatterOptions { get set }
}
