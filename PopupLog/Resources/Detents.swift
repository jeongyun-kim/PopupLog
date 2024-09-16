//
//  Detents.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI

extension Resources {
    enum Detents: CaseIterable {
        case mid
        case large
        
        var detents: PresentationDetent {
            switch self {
            case .mid:
                return .fraction(0.3)
            case .large:
                return .fraction(0.7)
            }
        }
    }
}
