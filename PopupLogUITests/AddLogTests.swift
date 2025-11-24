//
//  AddLogTests.swift
//  PopupLogUITests
//
//  Created by 김정윤 on 11/23/25.
//

import XCTest

final class AddLogTests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]  // 테스트 모드로 실행
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    // MARK: 제목본문 입력 후 로그 저장
    func test_제목본문_입력_로그저장() {
        // 1. Given: 기록하기 버튼 찾기
        let logAddButton = app.buttons["AddLog"]
        XCTAssertTrue(logAddButton.waitForExistence(timeout: 3))
        
        // 2. When: 기록하기로 접근
        logAddButton.tap()
        
        // - 제목 입력
        let titleField = app.textFields["LogTitleTextField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("성수동 팝업 방문!!")
        
        // - 본문 입력
        let contentField = app.textViews.element(boundBy: 0)
        contentField.tap()
        contentField.typeText("PopupLog UI Testing 😄")
        app.tap() // 키보드 내리기
        
        // - 저장 버튼 탭
        let saveButton = app.buttons["SaveLogButton"]
        XCTAssertTrue(saveButton.isEnabled, "제목, 본문 입력 시 저장 버튼이 활성화되어야 함")
        saveButton.tap()
        
        XCTAssertFalse(titleField.exists, "저장 후 기록하기 화면이 닫혀야 함")
    }
    
    // MARK: 제목만 입력 -> 저장버튼 비활성화
    func test_제목만_입력하면_저장버튼_비활성화() {
        // 1. Given: 기록하기 버튼 찾기
        let logAddButton = app.buttons["AddLog"]
        XCTAssertTrue(logAddButton.waitForExistence(timeout: 3))
        
        // 2. When : 기록하기로 접근 후 제목만 입력
        logAddButton.tap()
        
        // - 제목 입력
        let titleField = app.textFields["LogTitleTextField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("성수동 팝업 방문!!")
        app.tap()  // 키보드 내리기
        
        // Then: 저장 버튼 비활성화
        let saveButton = app.buttons["SaveLogButton"]
        XCTAssertFalse(saveButton.isEnabled, "본문이 비어있으면 저장 버튼이 비활성화되어야 함")
    }
    
    // MARK: 본문만 입력 -> 저장버튼 비활성화
    func test_본문만_입력하면_저장버튼_비활성화() {
        // 1. Given: 기록하기 버튼 찾기
        let logAddButton = app.buttons["AddLog"]
        XCTAssertTrue(logAddButton.waitForExistence(timeout: 3))
        
        // 2. When : 기록하기로 접근 후 본문만 입력
        logAddButton.tap()
        
        // - 본문 입력
        let contentField = app.textViews.element(boundBy: 0)
        contentField.tap()
        contentField.typeText("PopupLog UI Testing 😄")
        app.tap() // 키보드 내리기
        
        // Then: 저장 버튼 비활성화
        let saveButton = app.buttons["SaveLogButton"]
        XCTAssertFalse(saveButton.isEnabled,"제목이 비어있으면 저장 버튼이 비활성화되어야 함")
    }
    
    // MARK: 공백만 입력 -> 저장버튼 비활성화
    func test_공백만_입력하면_저장버튼_비활성화() {
        // 1. Given: 기록하기 버튼 찾기
        let logAddButton = app.buttons["AddLog"]
        XCTAssertTrue(logAddButton.waitForExistence(timeout: 3))
        
        // 2. When : 기록하기로 접근 후 제목만 입력
        logAddButton.tap()
        
        // - 제목 입력
        let titleField = app.textFields["LogTitleTextField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("  ")
        
        // - 본문 입력
        let contentField = app.textViews.element(boundBy: 0)
        contentField.tap()
        contentField.typeText("  ")
        app.tap() // 키보드 내리기
        
        // Then: 저장 버튼 비활성화
        let saveButton = app.buttons["SaveLogButton"]
        XCTAssertFalse(saveButton.isEnabled, "제목, 본문 공백이면 저장 버튼이 비활성화되어야 함")
    }
    
    // MARK: 장소 검색창 잘 뜨는지
    func test_장소_검색버튼_탭() {
        // 1. Given: 기록하기 버튼 찾기
        let logAddButton = app.buttons["AddLog"]
        XCTAssertTrue(logAddButton.waitForExistence(timeout: 3))
        
        // 2. When : 기록하기로 접근 후 장소 검색
        logAddButton.tap()
        
        // 장소 검색 버튼 탭
        let placeButton = app.buttons["장소를 검색해보세요 👀"]
        XCTAssertTrue(placeButton.waitForExistence(timeout: 2))
        placeButton.tap()
        
        // 3. Then: 검색 Sheet가 나타남
        let searchField = app.textFields["장소를 검색해보세요"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2), "장소 검색 Sheet가 나타나야 함")
    }
    
    // MARK: 태그 모아보기
    func test_태그_모두보기_탭() {
        // 1. Given: 기록하기 버튼 찾기
        let logAddButton = app.buttons["AddLog"]
        XCTAssertTrue(logAddButton.waitForExistence(timeout: 3))
        
        // 2. When : 기록하기로 접근 후 태그 모아보기
        logAddButton.tap()
        
        let allTagsButton = app.buttons["모두 보기"]
        XCTAssertTrue(allTagsButton.waitForExistence(timeout: 2))
        allTagsButton.tap()
        
        // 3. Then: 태그 목록 Sheet가 나타남
        let tagListTitle = app.navigationBars["태그 목록"]
        XCTAssertTrue(
            tagListTitle.waitForExistence(timeout: 2),
            "태그 목록 Sheet가 나타나야 함"
        )
    }
    
    // MARK: 태그 선택
    func test_태그_선택() {
        // 1. Given: 기록하기 버튼 찾기
        let logAddButton = app.buttons["AddLog"]
        XCTAssertTrue(logAddButton.waitForExistence(timeout: 3))
        
        // 2. When : 기록하기로 접근 후 태그 탭
        logAddButton.tap()
        
        // 첫 번째 태그 탭 (스크롤뷰에 있음)
        let tag = app.buttons["Tag_6911864c81f2cff98eb097f8"].firstMatch
        XCTAssertTrue(tag.waitForExistence(timeout: 2), "첫 번째 태그가 존재해야 함")
        tag.tap()
        
        // 3. Then: 태그가 선택된 상태로 표시됨
        let selectedTag = app.buttons["Tag_6911864c81f2cff98eb097f8_Selected"]
        XCTAssertTrue(selectedTag.exists, "태그가 선택된 상태로 표시되어야 함")
    }
    
    func test_전체_플로우_모든정보_입력후_저장() {
        // 1. Given: 기록하기 버튼 찾기
        let logAddButton = app.buttons["AddLog"]
        XCTAssertTrue(logAddButton.waitForExistence(timeout: 3))
        
        // 2. When : 기록하기로 접근 후 내용 작성
        logAddButton.tap()
        
        // - 제목 입력
        let titleField = app.textFields["LogTitleTextField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("성수동 팝업 방문!!")
        
        // - 태그 선택
        let tag = app.buttons["Tag_6911864c81f2cff98eb097f8"].firstMatch
        XCTAssertTrue(tag.waitForExistence(timeout: 2), "첫 번째 태그가 존재해야 함")
        tag.tap()
        // 태그가 선택된 상태로 표시됨
        let selectedTag = app.buttons["Tag_6911864c81f2cff98eb097f8_Selected"]
        XCTAssertTrue(selectedTag.exists, "태그가 선택된 상태로 표시되어야 함")
        
        // - 본문 입력
        let contentField = app.textViews["LogContentTextEditor"]
        contentField.tap()
        contentField.typeText("성수동 팝업을 다녀왔어용 😄")
        app.tap() // 키보드 내리기
    
        // - 저장
        let saveButton = app.buttons["SaveLogButton"]
        XCTAssertTrue(saveButton.isEnabled, "제목, 본문 입력 시 저장 버튼이 활성화되어야 함")
        saveButton.tap()
        
        XCTAssertFalse(titleField.exists, "저장 후 기록하기 화면이 닫혀야 함")
    }
}
