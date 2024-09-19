//
//  Tag.swift
//  PopupLog
//
//  Created by 김정윤 on 9/19/24.
//

import SwiftUI
import RealmSwift

final class Tag: Object, ObjectKeyIdentifiable {
    @Persisted (primaryKey: true) var id: ObjectId
    @Persisted var emoji: String
    @Persisted var tagName: String
    @Persisted var tagColor: String?
    
    convenience init(emoji: String, tagName: String, tagColor: String? = Resources.Colors.systemGray6.toHex()) {
        self.init()
        self.emoji = emoji
        self.tagName = tagName
        self.tagColor = tagColor
    }
}

struct DefaultTags {
    static let defaultTagList = [
        Tag(emoji: "😊", tagName: "기타"),
        Tag(emoji: "💖", tagName: "캐릭터", tagColor: "F3CCF3"),
        Tag(emoji: "💄", tagName: "뷰티", tagColor: "FED9ED"),
        Tag(emoji: "🧢", tagName: "의류", tagColor: "FBF0B2"),
        Tag(emoji: "🍰", tagName: "디저트", tagColor: "FFF4EA"),
        Tag(emoji: "📚", tagName: "문구", tagColor: "D5ED9F"),
        Tag(emoji: "💻", tagName: "전자기기", tagColor: "CAEDFF")
    ]
}

