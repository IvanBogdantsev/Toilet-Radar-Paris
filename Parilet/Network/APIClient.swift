//
//  APIClient.swift
//  Parilet
//
//  Created by Vanya Bogdantsev on 23.11.2022.
//

import Alamofire
import RxSwift

protocol APIClientProtocol {
    associatedtype RequestedType
    static func getDataset() -> Observable<RequestedType>
}

class APIClient<RequestedType: Codable>: APIClientProtocol {

    static func getDataset() -> Observable<RequestedType> {
        return request(APIRequest.getDataset)
    }

    private static func request<T: Codable> (_ apiRequest: URLRequestConvertible) -> Observable<T> {
        return Observable<T>.create { observer in
            let request = AF.request(apiRequest).responseDecodable { (response: DataResponse<T, AFError>) in
                
                switch response.result {
                case .success(let dataset):
                    observer.onNext(dataset)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }

    }

}
