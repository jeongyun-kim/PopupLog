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
        
    }
    
    struct Output {
        
    }
    
    var input = Input()
    @Published var output = Output()
    
    enum Inputs {
        
    }
    
    func action(_ input: Inputs) {
        
    }
    
}
