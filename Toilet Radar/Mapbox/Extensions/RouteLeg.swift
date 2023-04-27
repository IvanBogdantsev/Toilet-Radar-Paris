//
//  RouteLeg.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 19.03.2023.
//

import MapboxDirections
import MapboxMaps

extension RouteLeg {
    var shape: LineString {
        return steps.dropFirst().reduce(into: steps.first?.shape ?? LineString([])) { (result, step) in
            result.coordinates += (step.shape?.coordinates ?? []).dropFirst()
        }
    }
}
