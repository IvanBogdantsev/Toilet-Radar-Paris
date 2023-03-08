//
//  Double.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 06.03.2023.
//

extension Double {
    func roundedToClosestDivider(of divider: Double) -> Double {
        (self / divider).rounded() * divider
    }
}
