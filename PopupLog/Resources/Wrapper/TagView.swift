//
//  TagButtonWrapper.swift
//  PopupLog
//
//  Created by 김정윤 on 9/18/24.
//

import SwiftUI
import RealmSwift

struct TagView: View {
    @ObservedRealmObject var tag: Tag
    
    var body: some View {
        if let tagColor = tag.tagColor {
            HStack(spacing: 4) {
                Text(tag.emoji)
                Text(tag.tagName)
                    .font(Resources.Fonts.font14)
                    .foregroundStyle(.black)
            }
            .padding(6)
            .background(Color.init(hex: tagColor))
            .clipShape(.rect(cornerRadius: Resources.Radius.button))
        }
    }
}
