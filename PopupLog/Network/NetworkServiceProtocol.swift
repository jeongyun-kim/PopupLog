//
//  NetworkServiceProtocol.swift
//  PopupLog
//
//  Created by 김정윤 on 11/20/25.
//

import Foundation
import Alamofire

protocol NetworkServiceProtocol {
    func searchPlace(_ keyword: String, completionHandler: @escaping (Result<SearchPlaceResults, AFError>) -> Void)
}
