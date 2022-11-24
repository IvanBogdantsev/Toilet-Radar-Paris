//
//  APIClient.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 23.11.2022.
//

import Foundation
import Alamofire
import RxSwift

class APIClient {
    
    static func getDataset() -> Observable<Dataset> {
        return request(APIRequest.getDataset)
    }
    
    private static func request<T: Codable> (_ apiRequest: URLRequestConvertible) -> Observable<T> {
        return Observable<T>.create { observer in
            AF.request(apiRequest).responseDecodable { (response: DataResponse<T, AFError>) in
                    
            }
            
            
            return Disposables.create {
                
            }
        }
        
    }
    
}
