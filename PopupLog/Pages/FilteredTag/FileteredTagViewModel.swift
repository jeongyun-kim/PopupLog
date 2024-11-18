//
//  FileteredTagViewModel.swift
//  PopupLog
//
//  Created by 김정윤 on 11/18/24.
//

import Foundation
import Combine
import RealmSwift

final class FilteredTagViewModel: BaseViewModel {
    var subscriptions = Set<AnyCancellable>()
    var input = Input()
    @Published var output = Output()
    
    init() {
        transform()
    }
}

// MARK: Input / Output
extension FilteredTagViewModel {
    struct Input {
        let selectedTag = CurrentValueSubject<Tag, Never>(Tag(emoji: "😊", tagName: "전체"))
        let selectedLog = PassthroughSubject<Log, Never>()
        let toggleDetailView = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var filteredLogList: [Log] = []
        var selectedLog = Log()
        var selectedTag = Tag()
        var isPresentingDetailView = false
    }
}

// MARK: Actions
extension FilteredTagViewModel {
    enum Inputs {
        case selectedTag(tag: Tag)
        case selectedLog(log: Log)
        case toggleDetailView
    }
    
    func action(_ inputs: Inputs) {
        switch inputs {
        case .selectedLog(let log):
            input.selectedLog.send(log)
        case .selectedTag(let tag):
            input.selectedTag.send((tag))
        case .toggleDetailView:
            input.toggleDetailView.send(())
        }
    }
}

// MARK: Transform
extension FilteredTagViewModel {
    private func transform() {
        input.selectedTag
            .sink { [weak self] tag in
                guard let self else { return }
                self.output.selectedTag = tag
                guard tag.tagName == "전체" else {
                    self.output.filteredLogList = LogRepository.shared.getFilteredLogs(tag)
                    return
                }
                self.output.filteredLogList = LogRepository.shared.getAllLogs()
            }
            .store(in: &subscriptions)
        
        input.selectedLog
            .sink { [weak self] log in
                guard let self else { return }
                self.output.selectedLog = log
            }
            .store(in: &subscriptions)
        
        input.toggleDetailView
            .sink { [weak self] _ in
                guard let self else { return }
                self.output.isPresentingDetailView.toggle()
            }
            .store(in: &subscriptions)
    }
}
