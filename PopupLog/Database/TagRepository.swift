//
//  TagRepository.swift
//  PopupLog
//
//  Created by 김정윤 on 9/22/24.
//

import SwiftUI
import RealmSwift

final class TagRepository {
    private init() { }
    static let shared = TagRepository()
    private let realm = try! Realm()
    @ObservedResults(Tag.self) private var tagList
    
    func addDefaultTags() {
        guard tagList.isEmpty else { return }
        for tag in DefaultTags.defaultTagList {
            $tagList.append(tag)
        }
    }
    
}
