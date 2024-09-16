//
//  LazyNavigationView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI

struct LazyNavigationView<Content: View>: View { // 감싸줄 뷰 = Content
    // 감싸줄 뷰 빌드
    let build: () -> Content
    
    var body: some View {
        build()
    }
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
}
