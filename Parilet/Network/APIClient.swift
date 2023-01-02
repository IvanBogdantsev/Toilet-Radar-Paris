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
    func getData() -> Single<RequestedType>
}

final class APIClient<RequestedType: Codable>: APIClientProtocol {

    func getData() -> Single<RequestedType> {
        request(APIRequest.getData)
            .asSingle()
    }

    private func request<T: Codable> (_ apiRequest: URLRequestConvertible) -> Observable<T> {
        return Observable<T>.create { observer in
            let request = AF.request(apiRequest).responseDecodable { (response: DataResponse<T, AFError>) in
                switch response.result {
                case .success(let result):
                        observer.onNext(result)
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
