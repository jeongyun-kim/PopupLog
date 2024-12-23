//
//  ChartHeaderText.swift
//  PopupLog
//
//  Created by 김정윤 on 12/23/24.
//

import SwiftUI

private struct ChartHeaderText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Resources.Colors.lightGray)
            .font(.caption)
            .bold()
    }
}

extension View {
    public func asChartHeaderText() -> some View {
        modifier(ChartHeaderText())
    }
}
