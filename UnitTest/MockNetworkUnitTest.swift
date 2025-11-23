import XCTest
import Combine
@testable import PopupLog

final class MockNetworkUnitTest: XCTestCase {
    
    // 테스트에 사용할 변수
    var mockNetworkService: MockNetworkService!
    var sut: AddViewModel!
    var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = AddViewModel(networkService: mockNetworkService)
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDown() {
        mockNetworkService = nil
        sut = nil
        subscriptions = nil
        super.tearDown()
    }

    private let mockPlace = Place(
        title: "강남역 1번 출구",
        roadAddress: "서울시 강남구 강남대로 123",
        mapx: "127001",
        mapy: "37001"
    )
    
    private let keyword = "강남역"
    
    // MARK: - 장소 검색 관련 테스트
    // - 0.2초의 delay 시간은 응답값 받아와 combine 처리 시간
    // MARK: 장소 검색 성공
    func test_장소_검색_성공() {
        // 1. Given: 검색 키워드와 가짜 데이터
        let keyword = "강남역"
        // Mock 데이터 설정
        mockNetworkService.mockPlaceResult = SearchPlaceResults(
            total: 1,
            start: 1,
            items: [mockPlace]
        )
        
        // 2. When: 검색 실행
        // 비동기 실행을 위한 expectation
        let expectation = XCTestExpectation(description: "장소 검색 완료")
        sut.output.placeField = keyword
        sut.action(.searchPlace)
        
        // 3. Then: 0.2초 후 결과 확인
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.sut.output.searchedPlaces.count, 1)
            XCTAssertEqual(self.sut.output.searchedPlaces.first?.replacedTitle, "강남역 1번 출구")
            XCTAssertFalse(self.sut.output.isLoading, "로딩이 종료되어야 함")
            XCTAssertNil(self.sut.output.errorMessage, "에러 메시지가 없어야 함")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: 빈 키워드로 검색 -> 빈 결과
    func test_빈키워드_빈결과() {
        // 1. Given: 비어있는 검색 키워드
        let keyword = ""
    
        // 2. When: 검색 실행
        let expectation = XCTestExpectation(description: "빈 키워드 검색")
        sut.output.placeField = keyword
        sut.action(.searchPlace)
        
        // 3. Then: 검색결과 0개에 에러 메시지 없는 지 확인
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.sut.output.searchedPlaces.count, 0)
            XCTAssertNil(self.sut.output.errorMessage)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    // MARK: - 네트워크 에러 테스트
    
    // MARK: 인터넷 연결 끊김
    func test_인터넷_연결_끊김() {
        // 1. Given: 네트워크 연결 끊김 상태
        mockNetworkService.mockError = .networkDisconnected
        
        // 2. When: 검색 실행
        let expectation = XCTestExpectation(description: "인터넷 끊김")
        sut.output.placeField = keyword
        sut.action(.searchPlace)
        
        // 3. Then: 적절한 에러 메시지 표시
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // 에러 메시지가 설정되어야 함
            XCTAssertNotNil(self.sut.output.errorMessage,"에러 메시지가 있어야 합니다")
            // 인터넷 연결 관련 메시지인지 확인
            XCTAssertEqual(self.sut.output.errorMessage,"인터넷 연결을 확인해주세요")
            // 에러 Alert가 표시되어야 함
            XCTAssertTrue(self.sut.output.showError)
            // 검색 결과는 비어있어야 함
            XCTAssertEqual(self.sut.output.searchedPlaces.count, 0)
            // 로딩은 종료되어야 함
            XCTAssertFalse(self.sut.output.isLoading)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    // MARK: 타임아웃 에러
    func test_타임아웃_에러() {
        // 1. Given: 타임아웃 상태
        mockNetworkService.mockError = .timeout
        
        // 2. When
        let expectation = XCTestExpectation(description: "타임아웃")
        sut.output.placeField = keyword
        sut.action(.searchPlace)
        
        // 3. Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertNotNil(self.sut.output.errorMessage) // 에러 메시지 존재 확인
            
            // 타임아웃 관련 메시지인지 확인
            XCTAssertTrue(self.sut.output.errorMessage!.contains("불안정"),"타임아웃 메시지가 포함되어야 합니다")
            // 에러가 보이는지
            XCTAssertTrue(self.sut.output.showError)
            // 검색 결과가 없는지
            XCTAssertEqual(self.sut.output.searchedPlaces.count, 0)
            // 로딩이 끝났는지
            XCTAssertFalse(self.sut.output.isLoading)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    // MARK: 서버 에러
    func test_서버_에러() {
        // 1. Given: 서버 에러 상태
        mockNetworkService.mockError = .serverError
        
        // 2. When
        let expectation = XCTestExpectation(description: "서버 에러")
        sut.output.placeField = keyword
        sut.action(.searchPlace)
        
        // 3. Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertNotNil(self.sut.output.errorMessage)
            XCTAssertTrue(self.sut.output.showError)
            XCTAssertEqual(self.sut.output.searchedPlaces.count, 0)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    // MARK: 잘못된 응답 데이터
    func test_잘못된_응답_데이터() {
        // 1. Given: 파싱 실패 상태
        mockNetworkService.mockError = .invalidResponse
     
        // 2. When
        let expectation = XCTestExpectation(description: "파싱 실패")
        sut.output.placeField = keyword
        sut.action(.searchPlace)
        
        // 3. Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertNotNil(self.sut.output.errorMessage)
            XCTAssertTrue(self.sut.output.showError)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    // MARK: - 로딩 상태 테스트
    // MARK: 로딩 상태 확인
    func test_로딩_상태() {
        // 1. Given: 느린 응답 시뮬레이션 (1초 지연)
        mockNetworkService.responseDelay = 1.0
        mockNetworkService.mockError = .none // 정상
        
        // 2. When: 검색 시작
        let expectation = XCTestExpectation(description: "로딩 상태")
        sut.output.placeField = keyword
        sut.action(.searchPlace)
        
        // 3. Then: 0.1초 후 - 로딩 중이어야 함
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.sut.output.isLoading, "검색 중에는 로딩 상태여야 합니다")
        }
        
        // Then: 1.5초 후 - 로딩 종료
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertFalse(self.sut.output.isLoading,"검색 완료 후에는 로딩이 종료되어야 합니다")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    
    // MARK: 에러 발생 시 로딩 종료
    func test_에러발생시_로딩_종료() {
        // 1. Given
        mockNetworkService.mockError = .networkDisconnected
        
        // 2. When
        let expectation = XCTestExpectation(description: "에러 시 로딩 종료")
        sut.output.placeField = keyword
        sut.action(.searchPlace)
        
        // 3. Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // 에러가 발생했지만 로딩은 종료되어야 함
            XCTAssertFalse(self.sut.output.isLoading,"에러 발생 시에도 로딩은 종료되어야 합니다")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    // MARK: - 재시도 테스트
    // MARK: 에러 후 재시도 성공
    func test_에러후_재시도_성공() {
        // 1. Given: 첫 번째는 에러
        mockNetworkService.mockError = .networkDisconnected
       
        
        // 2. When: 첫 번째 시도
        let expectation = XCTestExpectation(description: "재시도 성공")
        sut.output.placeField = keyword
        sut.action(.searchPlace)
        
        // 3. Then: 에러 확인
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertNotNil(self.sut.output.errorMessage)
            XCTAssertTrue(self.sut.output.showError)
            
            // 성공 상태로 변경
            self.mockNetworkService.mockError = .none
            self.mockNetworkService.mockPlaceResult = SearchPlaceResults(
                total: 1,
                start: 1,
                items: [self.mockPlace]
            )
            
            // 재시도
            self.sut.action(.searchPlace)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                // 성공
                XCTAssertNil(self.sut.output.errorMessage, "재시도 성공 시 에러 메시지가 사라져야 합니다")
                XCTAssertFalse(self.sut.output.showError)
                XCTAssertEqual(self.sut.output.searchedPlaces.count, 1)
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    
    // MARK: 빈 키워드로 검색 시 에러 초기화
    func test_빈키워드_검색시_에러_초기화() {
        // 1. Given: 먼저 에러 발생
        mockNetworkService.mockError = .timeout
        
        // 2. When: 에러 발생한 채 시도
        let expectation = XCTestExpectation(description: "에러 초기화")
        sut.output.placeField = keyword
        sut.action(.searchPlace)
        
        // 3. Then: 에러 발생 후 에러 상태 초기화
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // 에러 발생 확인 -> 타임아웃 에러
            XCTAssertNotNil(self.sut.output.errorMessage)
            
           // 두번째 검색 -> 빈 문자열로
            self.sut.output.placeField = ""
            self.sut.action(.searchPlace)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // 에러 메시지 초기화 확인
                XCTAssertNil(self.sut.output.errorMessage, "빈 키워드 검색 시 에러 메시지가 초기화되어야 합니다")
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
