//
//  Network.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 23.12.2022.
//

struct NetworkingConstants {
    static let url = "https://opendata.paris.fr/api/records/1.0/search/?dataset=sanisettesparis&q=&rows=1000"
    
    init() {
        fatalError("\(String(describing: type(of: self))) cannot be constructed")
    }
}
