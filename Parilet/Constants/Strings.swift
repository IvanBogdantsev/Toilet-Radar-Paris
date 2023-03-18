//
//  Strings.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 11.03.2023.
//

import Foundation

struct Strings {
    static let works_24_7: String = {
        "works_24_7".localized()
    }()
    
    static let undefined: String = {
        "undefined".localized() 
    }()
    
    init() {
        fatalError("\(String(describing: type(of: self))) cannot be constructed")
    }
}
