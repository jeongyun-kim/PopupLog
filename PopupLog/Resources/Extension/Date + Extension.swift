//
//  Date + Extension.swift
//  PopupLog
//
//  Created by 김정윤 on 9/26/24.
//

import Foundation

extension Date {
    var formattedDate: String {
        return self.formatted(date: .numeric, time: .omitted)
    }
    
    var isToday: Bool {
        return formattedDate == Date().formatted(date: .numeric, time: .omitted)
    }
}
