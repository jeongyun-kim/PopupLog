//
//  MockNetworkUnitTest.swift
//  UnitTest
//
//  Created by 김정윤 on 11/20/25.
//

import XCTest
import Combine
@testable import PopupLog

final class MockNetworkUnitTest: XCTestCase {
    
    // 테스트에 사용할 변수
    var mockNetworkService: MockNetworkService!
    var sut: AddViewModel!
    var subscriptoins: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockNetworkService = .init()
        sut = AddViewModel(networkService: mockNetworkService)
        subscriptoins = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // 테스트 1: 장소 검색 성공
    func test_장소_검색_성공() {
        // 1. Given: 검색 키워드
        let keyword = "강남역"
        
        // 2. When: 장소 검색 실행
        // - XCTestExpectation: 비동기 네트워크 요청 기다림 의미
        let expectation = XCTestExpectation(description: "장소 검색 완료")
        mockNetworkService.searchPlace(keyword) { result in
            switch result {
            case .success(let value):
                XCTAssertGreaterThan(value.items.count, 0, "강남역 검색 시 결과 하나라도 존재")
                
                if let firstPlace = value.items.first {
                    // 해당 항목이 false 인지 확인
                    // - 타이틀과 도로명 주소가 존재하는지 확인
                    XCTAssertFalse(firstPlace.title.isEmpty, "장소명이 있어야 합니다")
                    XCTAssertFalse(firstPlace.roadAddress.isEmpty, "도로명 주소가 있어야 합니다")
                }
            case .failure(let error):
                XCTFail("장소 검색에 실패했습니다 : \(error)")
            }
            
            // 작업 완료
            expectation.fulfill()
        }
        // 최대 5초 대기 <- 네트워크 요청에 걸릴 시간 고려해서
        wait(for: [expectation], timeout: 5.0)
    }

    // 테스트 2: 빈 키워드로 검색했을 때 -> 빈 검색결과 오는지 확인
    func test_빈키워드_빈결과() {
        // 1. Given: 비어있는 검색 키워드
        let keyword = ""
        
        // 2. When: 네트워크 수행
        let expectation = XCTestExpectation(description: "빈 키워드로 검색했을 때")
        mockNetworkService.searchPlace(keyword) { result in
            switch result {
            case .success(let value):
                XCTAssertEqual(value.items.count, 0)
            case .failure(let error):
                XCTFail("빈 키워드로 검색 시 에러 발생")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // 테스트 3: 검색 속도 측정
    func test_검색_성능() {
        // measure: 코드 실행 시간을 측정
        self.measure {
            let keyword = "강남역"
            let expectation = XCTestExpectation(description: "성능 테스트")
            
            mockNetworkService.searchPlace(keyword) { _ in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
        // 실행 후 평균 시간, 표준 편차 등이 표시됨
    }

}
