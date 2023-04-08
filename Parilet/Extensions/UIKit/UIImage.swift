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
    
    static var location_fill: UIImage {
        UIImage(named: "location_fill") ?? UIImage()
    }
    
    static var location_hollow: UIImage {
        UIImage(named: "location") ?? UIImage()
    }
}
