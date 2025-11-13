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
    
    var yearAndMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-M"
        let result = dateFormatter.string(from: self)
        return result
    }
    
    var formattedDay: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd일"
        let result = dateFormatter.string(from: self)
        return result
    }
    
    var formattedE: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let result = dateFormatter.string(from: self)
        return result
    }
}
