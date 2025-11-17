//
//  LogRepository.swift
//  PopupLog
//
//  Created by 김정윤 on 9/20/24.
//

import Foundation
import RealmSwift

final class LogRepository {
    private init() {
        migrateRealmIfNeeded()
        configureRealm()
    }
    
    static let shared = LogRepository()
    private lazy var realm: Realm = {
        return try! Realm()
    }()
    
    private func migrateRealmIfNeeded() {
        let fileManager = FileManager.default
        
        guard let groupURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: AppGroupInfo.appGroupID
        ) else {
            print("❌ App Group을 찾을 수 없습니다")
            return
        }
        
        let newRealmURL = groupURL.appendingPathComponent("default.realm")
        
        // 이미 App Group에 파일이 있으면 마이그레이션 불필요
        if fileManager.fileExists(atPath: newRealmURL.path) {
            print("✅ 이미 App Group에 Realm 파일 존재")
            return
        }
        
        // 기존 Realm 경로 (앱 Documents 폴더)
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let oldRealmURL = documentDirectory.appendingPathComponent("default.realm")
        
        // 기존 파일이 있으면 복사
        if fileManager.fileExists(atPath: oldRealmURL.path) {
            do {
                // Realm 파일과 관련 파일들 모두 복사
                try fileManager.copyItem(at: oldRealmURL, to: newRealmURL)
                
                // .lock 파일도 있으면 복사
                let oldLockURL = documentDirectory.appendingPathComponent("default.realm.lock")
                let newLockURL = groupURL.appendingPathComponent("default.realm.lock")
                if fileManager.fileExists(atPath: oldLockURL.path) {
                    try? fileManager.copyItem(at: oldLockURL, to: newLockURL)
                }
                
                // .management 폴더도 있으면 복사
                let oldManagementURL = documentDirectory.appendingPathComponent("default.realm.management")
                let newManagementURL = groupURL.appendingPathComponent("default.realm.management")
                if fileManager.fileExists(atPath: oldManagementURL.path) {
                    try? fileManager.copyItem(at: oldManagementURL, to: newManagementURL)
                }
                
                print("✅ 기존 Realm 데이터를 App Group으로 복사 완료")
                print("📁 기존 경로: \(oldRealmURL)")
                print("📁 새 경로: \(newRealmURL)")
            } catch {
                print("❌ Realm 파일 복사 실패: \(error)")
            }
        } else {
            print("⚠️ 기존 Realm 파일이 없습니다 (새로운 사용자)")
        }
    }
    
    private func configureRealm() {
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppInfo.appGroupID
        ) else { return }
        
        let realmURL = groupURL.appendingPathComponent("default.realm")
        let config = Realm.Configuration(
            fileURL: realmURL,
            schemaVersion: 0
        )
        
        Realm.Configuration.defaultConfiguration = config
        print("📁 Realm 설정 완료: \(realmURL)")
    }
    
    // 모든 로그 리스트
    func getAllLogs() -> [Log] {
        return Array(realm.objects(Log.self))
    }
    
    // 가장 최근 로그
    func getLatestLog() -> Log? {
        let log = getAllLogs().last
        return log
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
