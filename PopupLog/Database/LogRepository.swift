//
//  LogRepository.swift
//  PopupLog
//
//  Created by 김정윤 on 9/20/24.
//

import Foundation
import RealmSwift

final class LogRepository {
    private init() {}
    static let shared = LogRepository()
    private let realm = try! Realm()
    
    // 모든 로그 리스트
    func getAllLogs() -> [Log] {
        return Array(realm.objects(Log.self))
    }
    
    // 태그로 필터링 된 로그 리스트 
    func getFilteredLogs(_ tag: Tag) -> [Log] {
        return getAllLogs().filter { log in
            log.tag == tag
        }
    }
    
    // 로그 업데이트
    func updateLog(_ log: Log?, title: String, content: String, place: DBPlace?, tag: Tag?, visitDate: Date) {
        guard let log else { return }
        do {
            try realm.write {
                let value = ["id": log.id, "title": title, "content": content, "tag": tag, "place": place, "visitDate": visitDate]
                realm.create(Log.self, value: value, update: .modified)
            }
        } catch {
            print("update fail")
        }
    }
    
    // 각 날짜의 첫번째 로그 데이터
    func getLogData(_ date: Date) -> Log? {
        let logs = Array(realm.objects(Log.self))
        let result = logs.filter { $0.visitDate.formattedDate == date.formattedDate }
        guard let firstData = result.first else { return nil }
        return firstData
    }
}
