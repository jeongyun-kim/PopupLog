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
    
    @ObservedResults(Log.self) private var logList
    private let realm = try! Realm()
    
    func readAllLogs() -> [Log] {
        return Array(logList)
    }

    func addLog(_ log: Log) {
        $logList.append(log)
    }
    
    func deleteLog(_ log: Log) {
        $logList.remove(log)
    }
    
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
    
    func searchLogs(_ keyword: String) -> [Log] {
        return readAllLogs().filter { $0.content.contains(keyword) }
    }
}
