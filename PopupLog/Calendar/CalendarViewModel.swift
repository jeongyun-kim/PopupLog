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
    }
    
    struct Output {
        var currentYearMonth = ""
        var randomTitle = ""
    }
    
    var input = Input()
    @Published var output = Output()
    
    enum Inputs {
        case viewOnAppear
        case changeCurrentPage(date: Date)
    }
    
    func action(_ inputs: Inputs) {
        switch inputs {
        case .viewOnAppear:
            input.viewOnAppear.send(())
        case .changeCurrentPage(let date):
            input.currentPage.send(date)
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
    }
    
}
