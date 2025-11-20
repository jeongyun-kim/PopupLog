//
//  AddUnitTest.swift
//  UnitTest
//
//  Created by 김정윤 on 11/20/25.
//

import XCTest
import Combine
@testable import PopupLog  // 내 앱의 모든 코드에 접근 가능하게 함 (앱 타겟 이름으로 변경 필요)

final class AddLogUnitTest: XCTestCase {
    // 테스트에 사용할 변수들
    // !를 붙이는 이유: setUp()에서 초기화할 예정
    var sut: AddViewModel!
    var subscriptions: Set<AnyCancellable>!
    
    // MARK: setUp & tearDown
    
    // setUp: 각 테스트 함수가 실행되기 전에 자동으로 호출
    // - 테스트에 필요한 객체들 초기화
    override func setUp() {
        super.setUp()  // 부모 클래스의 setUp도 호출 (관례)
        
        // 새로운 ViewModel 인스턴스 생성
        // - 각 테스트마다 초기화 된 상태로 시작하기 위해
        sut = AddViewModel()
        
        // Combine 구독 저장소 초기화
        subscriptions = Set<AnyCancellable>()
    }
    
    // tearDown: 각 테스트 함수가 실행된 후에 자동으로 호출
    // - 테스트에서 사용한 리소스를 정리 (메모리 해제)
    override func tearDown() {
        // 사용한 객체들을 nil로 설정해서 메모리 해제
        sut = nil
        subscriptions = nil
        super.tearDown()  // 부모 클래스의 tearDown도 호출 (관례)
    }
    
    // MARK: 입력 유효성 검증 테스트
    // 여기서부터 실제 테스트 함수들!
    // 함수 이름은 반드시 "test"로 시작해야 Xcode가 테스트로 인식함!!
    
    
    // 테스트 1: 제목과 본문이 모두 비어있을 때
    // - 저장 버튼 비활성화
    func test_저장버튼_제목과본문이_비어있으면_비활성화() {
        // GWT 패턴: Given - When - Then

        // 1. Given (준비): 테스트를 위한 초기 상태를 설정
        // - 제목과 본문이 비어있는 상황
        sut.output.titleField = ""
        sut.output.contentField = ""
        
        // 2. When (실행): 테스트하려는 동작 수행
        let isDisabled = sut.output.titleField.isEmptyRemovedSpace ||
                            sut.output.contentField.isEmptyRemovedSpace
        
        // 3. Then (검증): 결과가 예상대로인지 확인
        // 이 값이 True인지 확인
        // - isDisabled : 현재 비활성화 상태인지 여부
        // - msg : 테스트 실패 메시지
        XCTAssertTrue(isDisabled, "제목과 본문이 모두 비어있으면 저장 버튼이 비활성화되어야 합니다")
        // XCTAssertTrue: 값이 true인지 확인
    }
    
    
    // 테스트 2: 제목만 비어있을 때
    func test_저장버튼_제목이_비어있으면_비활성화() {
        // 1. Given: 제목은 비어있고, 본문은 채워진 상황
        sut.output.titleField = ""
        sut.output.contentField = "본문본문"
        
        // 2. When: 저장 가능 여부 확인
        let isSaveDisabled = sut.output.titleField.isEmptyRemovedSpace ||
                            sut.output.contentField.isEmptyRemovedSpace
        
        // 3. Then: 저장이 불가능해야 함
        XCTAssertTrue(isSaveDisabled, "제목이 비어있으면 저장 버튼이 비활성화되어야 합니다")
    }
    
    
    // 테스트 3: 본문만 비어있을 때
    func test_저장버튼_본문이_비어있으면_비활성화() {
        // 1. Given: 제목은 채워져있고, 본문은 비어있는 상황
        sut.output.titleField = "제목"
        sut.output.contentField = ""
        
        // 2. When: 저장 가능 여부 확인
        let isSaveDisabled = sut.output.titleField.isEmptyRemovedSpace ||
                            sut.output.contentField.isEmptyRemovedSpace
        
        // 3. Then: 저장 불가
        XCTAssertTrue(isSaveDisabled, "본문이 비어있으면 저장 버튼이 비활성화되어야 합니다")
    }
    
    
    // 테스트 4: 제목과 본문이 모두 입력되었을 때 (정상 케이스)
    func test_저장버튼_제목과본문이_입력되면_활성화() {
        // 1. Given: 제목과 본문 모두 입력된 상황
        sut.output.titleField = "맛집 방문"
        sut.output.contentField = "정말 맛있었어요!"
        
        // 2. When: 저장 가능 여부 확인
        let isSaveEnabled = !sut.output.titleField.isEmptyRemovedSpace &&
                           !sut.output.contentField.isEmptyRemovedSpace
        
        // 3. Then: 저장 가능
        XCTAssertTrue(isSaveEnabled, "제목과 본문이 모두 입력되면 저장 버튼이 활성화되어야 합니다")
    }
    
    
    // 테스트 5: 공백만 있는 경우
    func test_저장버튼_제목이_공백만_있으면_비활성화() {
        // 1. Given: 제목에 공백만 있는 상황
        sut.output.titleField = "   "
        sut.output.contentField = "본문본문"
        
        // 2. When: 저장 가능 여부 확인
        let isSaveDisabled = sut.output.titleField.isEmptyRemovedSpace ||
                            sut.output.contentField.isEmptyRemovedSpace
        
        // 3. Then: 공백은 유효한 입력이 아니므로 저장 불가
        XCTAssertTrue(isSaveDisabled, "제목이 공백만 있으면 저장 버튼이 비활성화되어야 합니다")
    }
    
    
    // 테스트 6: 본문이 공백만 있는 경우
    func test_저장버튼_본문이_공백만_있으면_비활성화() {
        // 1. Given: 본문에 공백만 있는 상황
        sut.output.titleField = "제목"
        sut.output.contentField = "   "
        
        // 2. When: 저장 가능 여부 확인
        let isSaveDisabled = sut.output.titleField.isEmptyRemovedSpace ||
                            sut.output.contentField.isEmptyRemovedSpace
        
        // 3. Then: 저장 불가
        XCTAssertTrue(isSaveDisabled, "본문이 공백만 있으면 저장 버튼이 비활성화되어야 합니다")
    }
    
    
    // MARK: 초기값 테스트
    // ViewModel이 생성될 때 초기값이 올바른지 확인
    
    // 테스트 7: ViewModel 생성 시 초기값 확인
    func test_초기값_설정() {
        // 1. Given: setUp()에서 이미 sut(ViewModel)이 생성됨
        // - 따라서 별도의 준비 과정 없음
        
        // 2. When: 초기값 확인을 위해 별도 동작 없음
        
        // 3. Then: 각 필드의 초기값을 확인
        // - XCTAssertEqual: 두 값이 같은지 확인
        //   - 첫 번째: 실제 값, 두 번째: 예상 값, 세 번째: 실패 메시지
        XCTAssertEqual(sut.output.titleField, "", "초기 제목은 빈 문자열이어야 합니다")
        XCTAssertEqual(sut.output.contentField, "", "초기 본문은 빈 문자열이어야 합니다")
        XCTAssertEqual(sut.output.place, "", "초기 장소는 빈 문자열이어야 합니다")
        
        // XCTAssertNil: 값이 nil인지 확인
        XCTAssertNil(sut.output.selectedTag, "초기 선택된 태그는 nil이어야 합니다")
        
        // XCTAssertFalse: 값이 false인지 확인
        XCTAssertFalse(sut.output.isEditMode, "초기 편집모드는 false여야 합니다")
    }
    
    // 테스트 8: 방문일 초기값이 오늘 날짜인지 확인
    func test_방문일_초기값은_현재날짜() {
        // 1. Given: 현재 시간
        let calendar = Calendar.current  // 캘린더 객체 생성
        let now = Date()  // 현재 시간
        
        // 2. When: 뷰모델이 가지는 초기 방문일
        let outputDate = sut.output.visitedDate  // ViewModel의 방문일
        
        // 3. Then: 두 날짜가 같은 날인지 확인
        let isSameDay = calendar.isDate(outputDate, inSameDayAs: now)
        XCTAssertTrue(isSameDay, "초기 방문일은 현재 날짜여야 합니다")
    }
    
    
    // MARK: Action 테스트 (비동기)
    // ViewModel의 action 메서드를 테스트
    // 테스트 9: 방문일 변경 액션 테스트
    func test_방문일_변경() {
        // 1. Given
        // - XCTestExpectation: 비동기 작업을 테스트하기 위한 도구
        //  - "이 작업이 완료될 때까지 기다려!" 라고 알려줌
        let expectation = XCTestExpectation(description: "방문일 변경")
        
        // 테스트할 날짜: 7일 전
        let testDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
        // 2. When: 방문일 변경 액션 실행
        sut.action(.visitedDate(date: testDate))
        
        // Combine이 비동기로 처리하므로 약간의 대기 시간 필요
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // 3. Then: 방문일이 올바르게 변경되었는지 확인
            // - 바뀐 방문일과 테스트할 날짜가 동일한 지 확인
            XCTAssertEqual(
                Calendar.current.startOfDay(for: self.sut.output.visitedDate),
                Calendar.current.startOfDay(for: testDate),
                "방문일이 올바르게 변경되어야 합니다"
            )
            
            // fulfill(): "기다리던 작업이 완료됨"을 알림
            expectation.fulfill()
        }
        
        // wait: expectation.fulfill()이 호출될 때까지 최대 1초 대기
        // - 1초 안에 fulfill()이 호출되지 않으면 테스트 실패
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    /// 테스트 10: 장소 제거 액션 테스트
    func test_장소_제거() {
        // Given
        let expectation = XCTestExpectation(description: "장소 제거")
        
        // 장소가 선택된 상황을 만듦
        sut.output.place = "강남역 팝업스토어"
        sut.output.selectedPlace = Place(title: "강남역 3출", roadAddress: "", mapx: "", mapy: "")
        
        // When: 장소 제거 액션 실행
        sut.action(.removePlace)
        
        // Then: 0.1초 후 장소가 제거되었는지 확인
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.output.place, "", "장소명이 빈 문자열이어야 합니다")
            XCTAssertNil(self.sut.output.selectedPlace, "선택된 장소가 nil이어야 합니다")
            XCTAssertNil(self.sut.output.selectedDBPlace, "DB 장소가 nil이어야 합니다")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - 자주 사용하는 XCTAssert 함수들 정리
    /*
     XCTAssertTrue(value)          : value가 true인지 확인
     XCTAssertFalse(value)         : value가 false인지 확인
     XCTAssertEqual(a, b)          : a와 b가 같은지 확인
     XCTAssertNotEqual(a, b)       : a와 b가 다른지 확인
     XCTAssertNil(value)           : value가 nil인지 확인
     XCTAssertNotNil(value)        : value가 nil이 아닌지 확인
     XCTAssertGreaterThan(a, b)    : a가 b보다 큰지 확인
     XCTAssertLessThan(a, b)       : a가 b보다 작은지 확인
     */
}
