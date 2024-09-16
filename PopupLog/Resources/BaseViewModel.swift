//
//  BaseViewModel.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import Foundation
import Combine

// 모든 뷰모델이 관찰되기위해 ObservableObject 채택
protocol BaseViewModel: ObservableObject {
    var subscriptions: Set<AnyCancellable> { get set }
    
    associatedtype Input
    associatedtype Output
    
    var input: Input { get set }
    var output: Output { get set }
    
    associatedtype Inputs
    
    func action(_ inputs: Inputs)
}
