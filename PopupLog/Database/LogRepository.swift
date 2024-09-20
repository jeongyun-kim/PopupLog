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
    
    func readAllLogs() -> [Log] {
        return Array(logList)
    }
    
    func addLog(_ log: Log) {
        $logList.append(log)
    }
    
    func deleteLog(_ log: Log) {
        $logList.remove(log)
    }
    
    func getFilteredLogs(_ date: Date) -> [Log] {
        let logs = readAllLogs()
        let result = logs.filter { $0.visitDate.formatted(date: .numeric, time: .omitted) == date.formatted(date: .numeric, time: .omitted) }
        return result
    }
    
    func searchLogs(_ keyword: String) -> [Log] {
        return readAllLogs().filter { $0.content.contains(keyword) }
    }
}
