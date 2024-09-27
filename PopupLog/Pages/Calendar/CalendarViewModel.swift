//
//  CalendarViewModel.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import Foundation
import Combine
import RealmSwift

final class CalendarViewModel: BaseViewModel {
    private let logRepo = LogRepository.shared
    var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    var input = Input()
    @Published var output = Output()
    
    init() {
        transform()
    }
}

// MARK: Input / Output
extension CalendarViewModel {
    struct Input {
        var viewOnAppear = PassthroughSubject<Void, Never>()
        var currentPage = CurrentValueSubject<Date, Never>(Date()) // 현재 캘린더의 년월
        var todayDate = CurrentValueSubject<Date, Never>(Date()) // 오늘 날짜
        var deleteLogImage = PassthroughSubject<String, Never>() // 이미지 삭제 버튼 탭
        var selectedLog = PassthroughSubject<Log, Never>() // 선택한 로그 -> 디테일뷰
        var toggleFullCover = PassthroughSubject<Void, Never>() // DetailView 띄우기
        var disappearedDetailView = PassthroughSubject<Bool, Never>() // DetailView 사라질 때 캘린더 reload 위한 신호
    }
    
    struct Output {
        var currentYearMonth = "" // 캘린더의 현재 달력 년월
        var randomTitle = "" // 캘린더뷰 내 타이틀
        var selectedDate = "" // 선택 날짜
        var selectedLog = Log(title: "", content: "", place: nil, visitDate: Date()) // DetailView로 넘겨줄 데이터
        var isPresentingFullCover = false // detailView presenting 상태
        var disappearedDetailView = false // detailView 닫힐 때
    }
}

// MARK: Actions
extension CalendarViewModel {
    enum Inputs {
        case viewOnAppear
        case changeCurrentPage(date: Date)
        case todayDate(date: Date)
        case deleteLogImage(id: String)
        case selectLog(log: Log)
        case toggleFullCover
        case disappearedDetailView(disappeared: Bool)
    }
    
    func action(_ inputs: Inputs) {
        switch inputs {
        case .viewOnAppear:
            input.viewOnAppear.send(())
        case .changeCurrentPage(let date):
            input.currentPage.send(date)
        case .todayDate(let today):
            input.todayDate.send(today)
        case .deleteLogImage(let id):
            input.deleteLogImage.send(id)
        case .selectLog(let log):
            input.selectedLog.send(log)
        case .toggleFullCover:
            input.toggleFullCover.send(())
        case .disappearedDetailView(let value):
            input.disappearedDetailView.send(value)
        }
    }
}

// MARK: Sink
extension CalendarViewModel {
    private func transform() {
        // viewOnAppear 시마다 필요한 정보 초기화
        input.viewOnAppear
            .sink { [weak self] _ in
                guard let self else { return }
                guard let title = Resources.titles.randomElement() else { return }
                // 제목 랜덤 지정
                self.output.randomTitle = title
                TagRepository.shared.addDefaultTags()
            }.store(in: &subscriptions)
        
        aboutCalendar()
        aboutLog()
        aboutDetailView()
    }
    
    // MARK: 달력 관련
    private func aboutCalendar() {
        // 사용자가 캘린더 셀 선택했을 때, 선택한 날짜
        input.todayDate
            .sink { [weak self] value in
                guard let self else { return }
                self.output.selectedDate = value.formattedDate
            }.store(in: &subscriptions)
        
        // 현재 보고있는 달력 스와이프시마다 보여주고 있는 날짜 받아오기
        input.currentPage
            .sink { [weak self] value in
                guard let self else { return }
                let dateComponents = Calendar.current.dateComponents([.month, .year], from: value)
                guard let month = dateComponents.month, let year = dateComponents.year else { return }
                self.output.currentYearMonth = "\(year)년 \(month)월"
            }.store(in: &subscriptions)
    }
    
    // MARK: 로그 삭제
    private func aboutLog() {
        // 사용자가 스와이프 통해 로그 삭제할 때
        input.deleteLogImage
            .sink { value in
                DocumentManager.shared.removeImage(id: value)
            }.store(in: &subscriptions)
    }
    
    // MARK: DetailView 관련
    private func aboutDetailView() {
        // DetailView로 보내는 사용자가 선택한 로그
        input.selectedLog
            .sink { [weak self] value in
                guard let self else { return }
                self.output.selectedLog = value
            }.store(in: &subscriptions)
        
        // DetailView 열지 말지
        input.toggleFullCover
            .sink { [weak self] _ in
                guard let self else { return }
                self.output.isPresentingFullCover.toggle()
            }.store(in: &subscriptions)
        
        // DetailView 사라졌을 때
        input.disappearedDetailView
            .sink { [weak self] value in
                guard let self else { return }
                self.output.disappearedDetailView = value
            }.store(in: &subscriptions)
    }
}
