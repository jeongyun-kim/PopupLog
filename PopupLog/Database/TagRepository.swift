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
    
    func addDefaultTags() {
        guard getAllTags().isEmpty else { return }
        for tag in DefaultTags.defaultTagList {
            addTag(tag)
        }
    }
    
    func addTag(_ tag: Tag) {
        do {
            try realm.write {
                realm.add(tag)
            }
        } catch {
            print("tag add error")
        }
    }
    
    func deleteTag(_ tag: Tag) {
        do {
            try realm.write {
                realm.delete(tag)
            }
        } catch {
            print("tag delete error")
        }
    }
    
    func getAllTags() -> Results<Tag> {
        return realm.objects(Tag.self)
    }
    
    func updateTag(_ tag: Tag, emoji: String?, tagName: String?, tagColor: String?) {
        do {
            try realm.write {
                let value = ["id": tag.id, "emoji": tag.emoji, "tagName": tagName, "tagColor": tagColor]
                realm.create(Tag.self, value: value, update: .modified)
            }
        } catch {
            print("tag update error")
        }
    }
}
