//
//  String.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 08.03.2023.
//

import Foundation
import UIKit

extension String {
    static var tick: String {
        "\u{2713}"
    }
    
    static var cross: String {
        "\u{2715}"
    }
}

extension String {
    func frTickCross() -> NSAttributedString {
        let string: String
        let color: UIColor
        switch self.lowercased() {
        case "oui": string = .tick ; color = .prlGreen
        case "non": string = .cross ; color = .red
        default: string = "?" ; color = .prlYellow
        }
        return NSAttributedString(string: string, color: color)
    }
}

extension String {
    func extractDigits() -> [Int] {
        self.components(separatedBy: .decimalDigits.inverted).compactMap { Int($0) }
    }
}

extension String {
    func localized() -> String {
        NSLocalizedString(self, comment: "")
    }
}

