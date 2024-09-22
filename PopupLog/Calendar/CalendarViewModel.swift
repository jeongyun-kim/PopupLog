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
    
    struct Input {
        var viewOnAppear = PassthroughSubject<Void, Never>()
        var currentPage = CurrentValueSubject<Date, Never>(Date())
        var todayDate = CurrentValueSubject<Date, Never>(Date())
        var sideMenuRowTapped = PassthroughSubject<Int, Never>()
        var deleteLog = PassthroughSubject<Log, Never>()
        var selectedLog = PassthroughSubject<Log, Never>()
        var toggleFullCover = PassthroughSubject<Void, Never>()
    }
    
    enum Inputs {
        case viewOnAppear
        case changeCurrentPage(date: Date)
        case todayDate(date: Date)
        case sideMenuRowTappedIdx(idx: Int)
        case deleteLog(log: Log)
        case selectLog(log: Log)
        case toggleFullCover
    }
    
    func action(_ inputs: Inputs) {
        switch inputs {
        case .viewOnAppear:
            input.viewOnAppear.send(())
        case .changeCurrentPage(let date):
            input.currentPage.send(date)
        case .todayDate(let today):
            input.todayDate.send(today)
        case .sideMenuRowTappedIdx(let idx):
            input.sideMenuRowTapped.send(idx)
        case .deleteLog(let log):
            input.deleteLog.send(log)
        case .selectLog(let log):
            input.selectedLog.send(log)
        case .toggleFullCover:
            input.toggleFullCover.send(())
        }
    }
    
    struct Output {
        var currentYearMonth = ""
        var randomTitle = ""
        var tappedMenuIdx = -1
        var selectedDate = ""
        var selectedLog = Log(title: "", content: "", place: nil, visitDate: Date())
        var isPresentingFullCover = false
    }
    
    init() {
        input.viewOnAppear
            .sink { [weak self] _ in
                guard let self else { return }
                guard let title = Resources.titles.randomElement() else { return }
                // 제목 랜덤 지정
                self.output.randomTitle = title
                // 사이드메뉴 누른 항목 초기화
                self.output.tappedMenuIdx = -1
            }.store(in: &subscriptions)
        
        input.currentPage
            .sink { [weak self] value in
                guard let self else { return }
                let dateComponents = Calendar.current.dateComponents([.month, .year], from: value)
                guard let month = dateComponents.month, let year = dateComponents.year else { return }
                self.output.currentYearMonth = "\(year)년 \(month)월"
            }.store(in: &subscriptions)
        
        input.sideMenuRowTapped
            .sink { [weak self] value in
                guard let self else { return }
                self.output.tappedMenuIdx = value
            }.store(in: &subscriptions)
        
        input.todayDate
            .sink { [weak self] value in
                guard let self else { return }
                self.output.selectedDate = value.formatted(date: .numeric, time: .omitted)
            }.store(in: &subscriptions)
        
        input.deleteLog
            .sink { [weak self] value in
                guard let self else { return }
                self.logRepo.deleteLog(value)
            }.store(in: &subscriptions)
        
        input.selectedLog
            .sink { [weak self] value in
                guard let self else { return }
                self.output.selectedLog = value
            }.store(in: &subscriptions)
        
        input.toggleFullCover
            .sink { [weak self] _ in
                guard let self else { return }
                self.output.isPresentingFullCover.toggle()
            }.store(in: &subscriptions)
    }
    
}
