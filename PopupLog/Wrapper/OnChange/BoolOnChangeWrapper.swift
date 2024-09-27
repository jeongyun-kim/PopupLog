//
//  BoolOnChangeWrapper.swift
//  PopupLog
//
//  Created by 김정윤 on 9/20/24.
//

import SwiftUI

struct BoolOnChangeWrapper: ViewModifier {
    @Binding var value: Bool
    let action: () -> Void
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .onChange(of: value) {
                    action()
                }
        } else {
            content
                .onChange(of: value, perform: { _ in
                    action()
                })
        }
    }
}

extension View {
    func changedBool(_ value: Binding<Bool>, action: @escaping () -> Void) -> some View {
        modifier(BoolOnChangeWrapper(value: value, action: action))
    }
}
