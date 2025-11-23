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
    enum MockNetworkError {
        case networkDisconnected // 인터넷 연결 끊김
        case timeout // 타임아웃
        case serverError // 서버 에러
        case invalidResponse // 잘못된 응답
        case none // 성공 = 에러X
    }
    
    // 반환할 가짜 데이터
    // - 에러 발생 시 외부에서 nil 주입
    var mockPlaceResult: SearchPlaceResults?
    var mockError: MockNetworkError = .none // 정상
    var responseDelay: TimeInterval = 0.0 // 응답 지연 시간
    
    func searchPlace(_ keyword: String, completionHandler: @escaping (Result<PopupLog.SearchPlaceResults, Alamofire.AFError>) -> Void) {
        // 시간 지연 구현을 위해  적용
        DispatchQueue.global().asyncAfter(deadline: .now() + responseDelay) {
            
            // 키워드가 비어있다면 빈 검색결과 반환
            guard !keyword.isEmpty else {
                completionHandler(.success(SearchPlaceResults(total: 0, start: 0, items: [])))
                return
            }
            
            switch self.mockError {
            case .networkDisconnected: // 인터넷 연결 끊김 에러
                let urlError = URLError(.notConnectedToInternet)
                let afError = AFError.sessionTaskFailed(error: urlError)
                completionHandler(.failure(afError))
                
            case .timeout: // 타임아웃 에러
                let urlError = URLError(.timedOut)
                let afError = AFError.sessionTaskFailed(error: urlError)
                completionHandler(.failure(afError))
                
            case .serverError: // 서버 에러 (500)
                let afError = AFError.responseValidationFailed(
                    reason: .unacceptableStatusCode(code: 500)
                )
                completionHandler(.failure(afError))
                
            case .invalidResponse: // 잘못된 응답 데이터
                let afError = AFError.responseValidationFailed(
                    reason: .dataFileNil
                )
                completionHandler(.failure(afError))
                
            case .none: // 성공
                if let mockPlaceResult = self.mockPlaceResult { // 결과가 있다면
                    completionHandler(.success(mockPlaceResult))
                } else {
                    // 없다면 기본 mock 데이터 전달
                    let defaultResult = SearchPlaceResults(total: 1, start: 1, items: [
                        Place(title: "테스트 장소", roadAddress: "1", mapx: "2", mapy: "3")
                    ])
                    completionHandler(.success(defaultResult))
                }
            }
        }
    }
    
}
