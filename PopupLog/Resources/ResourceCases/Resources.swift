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
        static let setting = Image(systemName: "gearshape.fill")
        static let search = Image(systemName: "magnifyingglass")
        static let plus = Image(systemName: "plus")
        static let chart = Image(systemName: "chart.bar")
        static let menu = Image(systemName: "line.3.horizontal")
        static let xmark = Image(systemName: "xmark")
        static let more = Image(systemName: "ellipsis.circle")
    }
    
    enum Colors {
        static let primaryColor = Color(hex: "FF8911")
        static let lightOrange = Color(hex: "FCECC7")
        static let moreLightOrange = Color(hex: "FFF6E3")
        static let primaryColorUK = UIColor(red: 1.00, green: 0.54, blue: 0.07, alpha: 1.00)
        static let white: Color = .white
        static let black: Color = .black
        static let systemGray6: Color = Color(.systemGray6)
        static let lightGray: Color = Color(.lightGray)
    }
    
    enum Fonts {
        static let bold15 = UIFont.systemFont(ofSize: 15, weight: .bold)
        static let regular14 = UIFont.systemFont(ofSize: 14)
        static let font14: Font = .system(size: 14)
    }
    
    enum Radius {
        static let button: CGFloat = 6
        static let textContents: CGFloat = 10
        static let bottomSheet: CGFloat = 42
        static let image: CGFloat = 12
        static let ticket: CGFloat = 20
    }
}
