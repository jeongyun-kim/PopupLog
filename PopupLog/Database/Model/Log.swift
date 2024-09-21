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
    @Persisted var place: DBPlace?
    @Persisted var tag: Tag?
    @Persisted var visitDate: Date
    @Persisted var regDate: Date
    
    convenience init(content: String, place: DBPlace?, tag: Tag? = nil, visitDate: Date) {
        self.init()
        self.content = content
        self.place = place
        self.tag = tag
        self.visitDate = visitDate
        self.regDate = Date()
    }
}
