//
//  DetailViewModel.swift
//  PopupLog
//
//  Created by 김정윤 on 9/21/24.
//

import Foundation
import Combine
import RealmSwift

final class DetailViewModel: BaseViewModel {
    var subscriptions = Set<AnyCancellable>()
    var input = Input()
    @Published var output = Output()
    
    struct Input {
        let deleteBtnTapped = PassthroughSubject<Void, Never>()
        let flip = PassthroughSubject<Void, Never>()
        let logData = PassthroughSubject<Log, Never>()
        let viewOnAppear = PassthroughSubject<Void, Never>()
    }
    
    enum Inputs {
        case deleteLog // 로그 삭제 
        case flip // 화면 앞/뒤면 상태
        case logData(log: Log) // 이전 뷰로부터 온 데이터
        case viewOnAppear // 변경된 데이터 업데이트
    }
    
    func action(_ inputs: Inputs) {
        switch inputs {
        case .deleteLog:
            return input.deleteBtnTapped.send(())
        case .flip:
            return input.flip.send(())
        case .logData(let log):
            return input.logData.send(log)
        case .viewOnAppear:
            return input.viewOnAppear.send(())
        }
    }
    
    struct Output {
        var isFlipped = false
        var log = Log(title: "", content: "", place: nil, visitDate: Date())
    }
    
    init() {
        input.deleteBtnTapped
            .sink { [weak self] _ in
                guard let self else { return }
                let log = self.output.log
                LogRepository.shared.deleteLog(log)
            }.store(in: &subscriptions)
        
        input.flip
            .sink { [weak self] _ in
                guard let self else { return }
                self.output.isFlipped.toggle()
            }.store(in: &subscriptions)
        
        input.logData
            .sink { [weak self] value in
                guard let self else { return }
                self.output.log = value
            }.store(in: &subscriptions)
        
        input.viewOnAppear
            .sink { [weak self] _ in
                guard let self else { return }
                guard let newLog = LogRepository.shared.getUpdatedLog(self.output.log) else { return }
                self.output.log = newLog
            }.store(in: &subscriptions)
    }
}
