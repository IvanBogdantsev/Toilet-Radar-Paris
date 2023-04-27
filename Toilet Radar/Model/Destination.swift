//
//  Destination.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 02.02.2023.
//

struct Destination {
    let prmAccess: String?
    let schedule: String?
    let district: String?
    let type: String?
    let address: String?
    
    init(destinationInfo: Dictionary<String, Any>) {
        prmAccess = destinationInfo[UserInfo.accesPmr.rawValue] as? String
        schedule = destinationInfo[UserInfo.horaire.rawValue] as? String
        district = destinationInfo[UserInfo.arrondissement.rawValue] as? String
        type = destinationInfo[UserInfo.type.rawValue] as? String
        address = destinationInfo[UserInfo.adresse.rawValue] as? String
    }
}
