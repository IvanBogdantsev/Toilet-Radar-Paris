//
//  UIImage.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 27.11.2022.
//

import UIKit

extension UIImage {
    static var pin: UIImage {
        UIImage(named: "red_pin") ?? UIImage()
    }
    
    static var locationArrow: UIImage {
        UIImage(named: "location_fill") ?? UIImage()
    }
}
