//
//  UIColor.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 08.03.2023.
//

import UIKit

extension UIColor {
    static func hex(_ value: UInt32) -> UIColor {
        let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((value & 0xFF00) >> 8) / 255.0
        let b = CGFloat(value & 0xFF) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
      }
}

extension UIColor {
    static var prlYellow: UIColor {
        UIColor.hex(0xF7B713)
    }
    static var prlGreen: UIColor {
        UIColor.hex(0x0BCE17)
    }
}
