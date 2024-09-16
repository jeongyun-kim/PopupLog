//
//  CalendarViewModel.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import Foundation
import Combine

final class CalendarViewModel: BaseViewModel {
    var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    
    struct Input {
        var viewOnAppear = PassthroughSubject<Void, Never>()
        var currentPage = CurrentValueSubject<Date, Never>(Date())
        var todayDate = CurrentValueSubject<Date, Never>(Date())
        var sideMenuRowTapped = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        var currentYearMonth = ""
        var randomTitle = ""
        var tappedMenuIdx = -1
    }
    
    var input = Input()
    @Published var output = Output()
    
    enum Inputs {
        case viewOnAppear
        case changeCurrentPage(date: Date)
        case todayDate(date: Date)
        case sideMenuRowTappedIdx(idx: Int)
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
        }
    }
    
    init() {
        input.viewOnAppear
            .sink { [weak self] _ in
                guard let self else { return }
                guard let title = Resources.titles.randomElement() else { return }
                self.output.randomTitle = title
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
    }
    
}
