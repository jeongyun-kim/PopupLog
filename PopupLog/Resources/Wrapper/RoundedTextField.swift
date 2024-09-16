//
//  RoundedTextField.swift
//  PopupLog
//
//  Created by 김정윤 on 9/17/24.
//

import SwiftUI

private struct RoundedTextField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.plain)
            .clipShape(Capsule())
            .padding()
            .overlay(RoundedRectangle(cornerRadius: Resources.Radius.textField)
                .strokeBorder(Resources.Colors.lightGray, style: StrokeStyle(lineWidth: 1.0)))
            .padding(.horizontal)
    }
}

extension View {
    func asRoundedTextField() -> some View {
        modifier(RoundedTextField())
    }
}
