//
//  MockNetworkService.swift
//  UnitTest
//
//  Created by 김정윤 on 11/20/25.
//

import Foundation
import Alamofire
@testable import PopupLog

final class MockNetworkService: NetworkServiceProtocol {
    func searchPlace(_ keyword: String, completionHandler: @escaping (Result<PopupLog.SearchPlaceResults, Alamofire.AFError>) -> Void) {
        // 반환할 가짜 데이터
        var mockPlaceResult: SearchPlaceResults?
        // 에러 반환 여부
        var isError = false
    
        // 키워드가 비어있다면 빈 검색결과 반환 
        guard !keyword.isEmpty else {
            completionHandler(.success(SearchPlaceResults(total: 0, start: 0, items: [])))
            return
        }
        
        if isError {
            let error = AFError.responseValidationFailed(reason: .dataFileNil)
            completionHandler(.failure(error))
            return 
        }
        
        // 성공 결과가 있다면
        if let mockPlaceResult {
            completionHandler(.success(mockPlaceResult))
        } else {
            // 없다면
            let defaultResult = SearchPlaceResults(total: 1, start: 1, items: [
                Place(title: "테스트 장소", roadAddress: "1", mapx: "2", mapy: "3")
            ])
            completionHandler(.success(defaultResult))
        }
    }
    
    
}
