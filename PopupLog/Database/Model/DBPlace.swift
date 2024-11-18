//
//  DBPlace.swift
//  PopupLog
//
//  Created by 김정윤 on 9/21/24.
//

import Foundation
import RealmSwift

final class DBPlace: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String?
    @Persisted var roadAddress: String?
    @Persisted var mapX: String?
    @Persisted var mapY: String?
    @Persisted var link: String?
    
    convenience init(title: String? = nil, roadAddress: String? = nil, mapX: String? = nil, mapY: String? = nil, link: String? = nil) {
        self.init()
        self.title = title
        self.roadAddress = roadAddress
        self.mapX = mapX
        self.mapY = mapY
        self.link = link
    }
}
