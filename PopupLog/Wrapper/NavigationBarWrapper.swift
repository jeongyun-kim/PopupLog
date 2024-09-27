//
//  NavigationBarWrapper.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI

// NavigationBar 구성
// - 좌우 뷰 구성 가능
struct NavigationBarWrapper<Leading: View, Trailing: View>: ViewModifier {
    let leading: Leading
    let trailing: Trailing
    
    init(@ViewBuilder leading: () -> Leading, @ViewBuilder trailing: () -> Trailing) {
        self.leading = leading()
        self.trailing = trailing()
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading, content: { leading })
                ToolbarItem(placement: .topBarTrailing, content: { trailing })
            }
    }
}

extension View {
    func navigationBar(@ViewBuilder leading: () -> some View, @ViewBuilder trailing: () -> some View) -> some View {
        modifier(NavigationBarWrapper(leading: leading, trailing: trailing))
    }
}
