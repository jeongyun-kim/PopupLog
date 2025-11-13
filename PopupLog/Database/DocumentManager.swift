//
//  DocumentManager.swift
//  PopupLog
//
//  Created by 김정윤 on 9/21/24.
//

import WidgetKit
import UIKit
import SwiftUI

final class DocumentManager {
    private init() { }
    static let shared = DocumentManager()
    private let fileManager = FileManager.default
    
    // App Group 경로
    func getFolderPath() -> URL? {
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: AppInfo.appGroupID) else {
            return nil
        }
        let folderURL = containerURL.appendingPathComponent("popuplog")
        return folderURL
    }
    
    func createFolder() {
        guard let folderPath = getFolderPath() else { return }
        if !fileManager.fileExists(atPath: folderPath.path) {
            do {
                try fileManager.createDirectory(at: folderPath, withIntermediateDirectories: true)
                print("폴더 생성 완료: \(folderPath.path)")
            } catch {
                print("폴더 생성 실패:", error)
            }
        }
    }
    
    func saveImage(id: String, image: UIImage) {
        guard let folderPath = getFolderPath() else { return }
        createFolder()
        
        guard let data = image.jpegData(compressionQuality: 0.3) else { return }
        let fileURL = folderPath.appendingPathComponent("\(id).jpg", conformingTo: .jpeg)
        
        do {
            try data.write(to: fileURL)
            print("이미지 저장 완료: \(fileURL.path)")
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("이미지 저장 실패:", error)
        }
    }
    
    func loadImage(id: String) -> UIImage? {
        guard let folderPath = getFolderPath() else { return nil }
        
        let fileURL = folderPath.appendingPathComponent("\(id).jpg", conformingTo: .jpeg)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            print("이미지 없음: \(fileURL.path)")
            return nil
        }
    }
    
    func loadImageForWidget(id: String) -> UIImage? {
        guard let folderPath = getFolderPath() else { return nil }
          let fileURL = folderPath.appendingPathComponent("\(id).jpg", conformingTo: .jpeg)
          
          guard fileManager.fileExists(atPath: fileURL.path),
                let image = UIImage(contentsOfFile: fileURL.path) else {
              print("이미지 없음 또는 로드 실패: \(fileURL.path)")
              return nil
          }

          let targetMaxSide: CGFloat = 600 // 위젯용 해상도
          let scale = min(targetMaxSide / image.size.width, targetMaxSide / image.size.height, 1)
          let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

          UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
          image.draw(in: CGRect(origin: .zero, size: newSize))
          let resized = UIGraphicsGetImageFromCurrentImageContext()
          UIGraphicsEndImageContext()

          // 압축
          guard let data = resized?.jpegData(compressionQuality: 0.2),
                let compressedImage = UIImage(data: data) else {
              return resized ?? image
          }

          return compressedImage
    }
    
    func removeImage(id: String) {
        guard let folderPath = getFolderPath() else { return }
        let fileURL = folderPath.appendingPathComponent("\(id).jpg", conformingTo: .jpeg)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
                print("이미지 삭제 완료: \(fileURL.path)")
            } catch {
                print("이미지 삭제 실패:", error)
            }
        } else {
            print("삭제할 이미지 없음: \(fileURL.path)")
        }
    }
}

extension DocumentManager {
    func migrateToAppGroupIfNeeded() {
        let migratedKey = "didMigrateToAppGroup"
        let defaults = UserDefaults.standard
        
        // 이미 마이그레이션을 한 적 있다면 종료
        if defaults.bool(forKey: migratedKey) {
            return
        }
        
        // 기존 Documents/popuplog 폴더 경로
        guard let oldFolderURL = try? fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent("popuplog") else {
            return
        }
        
        // 기존 폴더가 없으면 종료
        guard fileManager.fileExists(atPath: oldFolderURL.path) else {
            print("이전 popuplog 폴더 없음")
            return
        }
        
        // App Group 폴더 생성 및 경로 확보
        createFolder()
        guard let newFolderURL = getFolderPath() else { return }
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: oldFolderURL, includingPropertiesForKeys: nil)
            
            for fileURL in fileURLs {
                let destinationURL = newFolderURL.appendingPathComponent(fileURL.lastPathComponent)
                
                // 같은 이름의 파일이 없다면 복사
                if !fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.copyItem(at: fileURL, to: destinationURL)
                    print("파일 이동 완료: \(fileURL.lastPathComponent)")
                }
            }
            
            // 원본 폴더 삭제
            try fileManager.removeItem(at: oldFolderURL)
            print("기존 폴더 삭제 완료")
            
            // 마이그레이션 완료 플래그 저장
            defaults.set(true, forKey: migratedKey)
            
        } catch {
            print("AppGroup 마이그레이션 실패:", error)
        }
    }
}
