//
//  TagButtonWrapper.swift
//  PopupLog
//
//  Created by 김정윤 on 9/18/24.
//

import SwiftUI
import RealmSwift

struct TagButton: View {
    @ObservedRealmObject var tag: Tag
    let action: () -> Void
    
    var body: some View {
        if let tagColor = tag.tagColor {
            Button(action: action, label: {
                HStack(spacing: 4) {
                    Text(tag.emoji)
                    Text(tag.tagName)
                        .font(Resources.Fonts.font14)
                        .foregroundStyle(Resources.Colors.black)
                }
                .padding(6)
                .background(Color.init(hex: tagColor))
                .clipShape(.rect(cornerRadius: Resources.Radius.button))
            })
        }
    }
    
    
}
