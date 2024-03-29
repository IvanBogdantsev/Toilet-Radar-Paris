//
//  ApiRequest.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 23.11.2022.
//

import Foundation
import Alamofire

enum APIRequest: URLRequestConvertible {
    case getData
}

extension APIRequest {
    
    internal func asURLRequest() throws -> URLRequest {
        let url = try NetworkingConstants.url.asURL()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }

    private var method: HTTPMethod {
        switch self {
        case .getData:
            return .get
        }
    }

}
