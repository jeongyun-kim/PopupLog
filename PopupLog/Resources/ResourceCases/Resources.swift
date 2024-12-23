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
        static let tagSetting = Image(systemName: "tag.fill")
        static let search = Image(systemName: "magnifyingglass")
        static let plusUK = UIImage(systemName: "plus")!
        static let plus = Image(systemName: "plus")
        static let chart = Image(systemName: "chart.bar")
        static let menu = Image(systemName: "line.3.horizontal")
        static let xmark = Image(systemName: "xmark")
        static let more = Image(systemName: "ellipsis.circle")
        static let next = Image(systemName: "chevron.right")
        static let ticket = UIImage(named: "ticketDefaultImage")!
        static let darkTicket = UIImage(named: "ticketDefaultImage_dark")!
        static let hashTag = Image(systemName: "number")
        static let logo = UIImage(named: "logo")!
    }
    
    enum Colors {
        static let primaryColor = Color("primaryColor", bundle: .main)
        static let lightOrange = Color("lightOrange", bundle: .main)
        static let moreLightOrange = Color("moreLightOrange", bundle: .main)
        static let white = Color("white", bundle: .main)
        static let black = Color("black", bundle: .main)
        static let systemGray6: Color = Color(.systemGray6)
        static let lightGray: Color = Color(.lightGray)
    }
    
    enum Fonts {
        static let bold13: Font = .system(size: 13, weight: .bold)
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
