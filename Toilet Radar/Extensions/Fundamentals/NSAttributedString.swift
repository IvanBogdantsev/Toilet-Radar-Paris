//
//  NSAttributedString.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 12.03.2023.
//

import Foundation
import UIKit

extension NSAttributedString {
    convenience init(string: String, color: UIColor) {
        self.init(string: string, attributes: [.foregroundColor : color])
    }
}
