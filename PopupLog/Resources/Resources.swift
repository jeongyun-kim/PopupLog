//
//  Resources.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI
import UIKit

enum Resources {
    enum Images {
        static let setting = "gearshape.fill"
        static let search = "magnifyingglass"
        static let plus = "plus"
        static let chart = "chart.bar.fill"
        static let menu = "line.3.horizontal"
    }
    
    enum Colors {
        static let primaryColor = Color(hex: 0xFF8911)
        static let lightOrange = Color(hex: 0xfcecc7)
        static let primaryColorUK = UIColor(red: 1.00, green: 0.54, blue: 0.07, alpha: 1.00)
        static let white: Color = .white
        static let black: Color = .black
        static let systemGray6: Color = Color(.systemGray6)
        static let lightGray: Color = Color(.lightGray)
    }
    
    enum Fonts {
        static let bold15 = UIFont.systemFont(ofSize: 15, weight: .bold)
        static let regular14 = UIFont.systemFont(ofSize: 14)
    }
    
    enum Radius {
        static let bottomSheet: CGFloat = 42
    }
    
    static let titles = [
        "✨ 오늘은 어떤 팝업을 다녀오셨나요?",
        "🔥 오늘도 화이팅하세요!",
        "✏️ 기록은 즐거운 일이에요 :D",
        "👀 최근에 다녀오신 팝업이 있나요?",
        "👍 바람쐬러 가볼까요?",
        "🤗 좋은 하루 되세요"
    ]
}
