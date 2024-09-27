//
//  SearchViewModel.swift
//  PopupLog
//
//  Created by 김정윤 on 9/27/24.
//

import Foundation
import Combine

final class SearchViewModel: BaseViewModel {
    var subscriptions = Set<AnyCancellable>()
    var input = Input()
    @Published var output = Output()
    
    struct Input {
        let changedKeyword = PassthroughSubject<Void, Never>()
        let selectedLog = PassthroughSubject<Log, Never>()
        let toggleDetailView = PassthroughSubject<Void, Never>()
    }
    
    enum Inputs {
        case selectedLog(log: Log)
        case changedKeyword
        case toggleDetailView
    }
    
    func action(_ inputs: Inputs) {
        switch inputs {
        case .selectedLog(let log):
            input.selectedLog.send(log)
        case .changedKeyword:
            input.changedKeyword.send(())
        case .toggleDetailView:
            input.toggleDetailView.send(())
        }
    }
    
    struct Output {
        var keyword = ""
        var selectedLog = Log()
        var emptyText = EmptyViewKeyword.emptyKeyword.rawValue
        var isPresentingDetailView = false
    }
    
    enum EmptyViewKeyword: String {
        case emptyKeyword = "🔍 제목을 통해 지금까지 \n저장한 기록들을 찾아보세요"
        case noResults = "🥲 검색결과가 없어요"
    }
    
    init() {
        input.selectedLog
            .sink { [weak self] value in
                guard let self else { return }
                output.selectedLog = value
            }.store(in: &subscriptions)
        
        input.changedKeyword
            .sink { [weak self] _ in
                guard let self else { return }
                let keyword = self.output.keyword
                self.output.emptyText = keyword.isEmpty ? EmptyViewKeyword.emptyKeyword.rawValue : EmptyViewKeyword.noResults.rawValue
            }.store(in: &subscriptions)
        
        input.toggleDetailView
            .sink { [weak self] _ in
                guard let self else { return }
                self.output.isPresentingDetailView.toggle()
            }.store(in: &subscriptions)

    }
}
