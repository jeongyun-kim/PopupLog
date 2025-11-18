//
//  NetworkService.swift
//  PopupLog
//
//  Created by 김정윤 on 9/19/24.
//

import Foundation
import Alamofire

final class NetworkService {
    private init() { }
    static let shared = NetworkService()
    
    func searchPlace(_ keyword: String, completionHandler: @escaping (Result<SearchPlaceResults, AFError>) -> Void) {
        let headerClient = BundleWrapper(.NClient).wrappedValue
        let headerSecret = BundleWrapper(.NSecret).wrappedValue
        let clientID = BundleWrapper(.clientID).wrappedValue
        let secretKey = BundleWrapper(.APIKey).wrappedValue
        let baseURL = BundleWrapper(.BaseURL).wrappedValue

        let params: Parameters = [
            "query": keyword,
            "display": 5
        ]
        
        let headers: HTTPHeaders = [
            headerClient: clientID,
            headerSecret: secretKey
        ]
        
        AF.request(baseURL, parameters: params, headers: headers).responseDecodable(of: SearchPlaceResults.self) { response in
            switch response.result {
            case .success(let value):
                completionHandler(.success(value))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}
