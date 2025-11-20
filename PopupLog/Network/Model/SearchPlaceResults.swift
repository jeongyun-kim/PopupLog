//
//  SearchPlaceResults.swift
//  PopupLog
//
//  Created by 김정윤 on 9/19/24.
//

import Foundation

struct SearchPlaceResults: Decodable {
    let total: Int
    let start: Int
    let items: [Place]
}

struct Place: Decodable, Hashable {
    let title: String
    let link: String
    let roadAddress: String
    let mapx: String
    let mapy: String
    let id: UUID
    
    var replacedTitle: String {
        var title = title.replacingOccurrences(of: #"</b>"#, with: "")
        title = title.replacingOccurrences(of: "<b>", with: "")
        return title
    }
    
    enum CodingKeys: CodingKey {
        case title
        case link
        case roadAddress
        case mapx
        case mapy
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.link = try container.decode(String.self, forKey: .link)
        self.roadAddress = try container.decode(String.self, forKey: .roadAddress)
        self.mapx = try container.decode(String.self, forKey: .mapx)
        self.mapy = try container.decode(String.self, forKey: .mapy)
        self.id = UUID()
    }
    
    // 테스트용 init
    init(title: String, link: String = "", roadAddress: String, mapx: String, mapy: String, id: UUID = UUID()) {
        self.title = title
        self.link = link
        self.roadAddress = roadAddress
        self.mapx = mapx
        self.mapy = mapy
        self.id = id
    }
}
