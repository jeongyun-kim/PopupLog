//
//  StringOnChangeWrapper.swift
//  PopupLog
//
//  Created by 김정윤 on 9/27/24.
//

import SwiftUI

struct StringOnChangeWrapper: ViewModifier {
    @Binding var text: String
    let action: () -> Void
        
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .onChange(of: text) {
                    action()
                }
        } else {
            content
                .onChange(of: text, perform: { _ in
                    action()
                })
        }
    }
}

extension View {
    func changedString(_ text: Binding<String>, action: @escaping () -> Void) -> some View {
        modifier(StringOnChangeWrapper(text: text, action: action))
    }
}
