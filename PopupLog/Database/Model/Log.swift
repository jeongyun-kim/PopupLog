//
//  Log.swift
//  PopupLog
//
//  Created by 김정윤 on 9/20/24.
//

import Foundation
import RealmSwift

final class Log: Object, ObjectKeyIdentifiable {
    @Persisted (primaryKey: true) var id: ObjectId
    @Persisted var content: String
    @Persisted var mapX: String?
    @Persisted var mapY: String?
    @Persisted var tag: Tag?
    @Persisted var thumb: String?
    @Persisted var visitDate: Date
    @Persisted var regDate: Date
    
    convenience init(content: String, mapX: String?, mapY: String?, tag: Tag? = nil, thumb: String? = nil, visitDate: Date) {
        self.init()
        self.content = content
        self.mapX = mapX
        self.mapY = mapY
        self.tag = tag
        self.thumb = thumb
        self.visitDate = visitDate
        self.regDate = Date()
    }
}
