//
//  TagButtonWrapper.swift
//  PopupLog
//
//  Created by 김정윤 on 9/18/24.
//

import SwiftUI

struct TagButton: View {
    let emoji: String
    let tagName: String
    let tagColor: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            HStack(spacing: 4) {
                Text(emoji)
                Text(tagName)
                    .font(Resources.Fonts.font14)
                    .foregroundStyle(Resources.Colors.black)
            }
            .padding(6)
            .background(Color.init(hex: tagColor))
            .clipShape(.rect(cornerRadius: Resources.Radius.button))
        })
    }
}
