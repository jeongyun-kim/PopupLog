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
