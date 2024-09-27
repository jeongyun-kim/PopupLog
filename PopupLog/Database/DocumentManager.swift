//
//  DocumentManager.swift
//  PopupLog
//
//  Created by 김정윤 on 9/21/24.
//

import UIKit
import SwiftUI

final class DocumentManager {
    private init() { }
    static let shared = DocumentManager()
    private let fileManager = FileManager.default
    
    func getFolderPath() -> URL? {
        // 폴더 경로 유효한지 확인
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let folderDirectory = documentDirectory.appendingPathComponent("popuplog")
        return folderDirectory
    }
    
    func createFolder() {
        guard let folderPath = getFolderPath() else { return }
        if !fileManager.fileExists(atPath: folderPath.path()) {
            do {
                try fileManager.createDirectory(at: folderPath, withIntermediateDirectories: true)
            } catch {
                print("failed to create folder")
            }
        } else {
            return 
        }
    }
    
    func saveImage(id: String, image: UIImage) {
        guard let folderPath = getFolderPath() else { return }
        createFolder()
        
        // 이미지 데이터 불러오기
        guard let data = image.jpegData(compressionQuality: 0.3) else { return }
        let imageName = "\(id).jpg"
        let fileURL = folderPath.appendingPathComponent(imageName, conformingTo: .jpeg)
        
        // 이미지 저장
        do {
            try data.write(to: fileURL)
        } catch {
            print("image save error")
        }
    }
    
    func loadImage(id: String) -> UIImage? {
        guard let folderPath = getFolderPath() else {
            return nil
        }
        
        let imageName = "\(id).jpg"
        let fileURL = folderPath.appendingPathComponent(imageName, conformingTo: .jpeg)
        
        // 이미지 있을 경우 이미지 보내고 아니면 다 nil
        if fileManager.fileExists(atPath: fileURL.path()) {
            guard let result =  UIImage(contentsOfFile: fileURL.path()) else {
                return nil
            }
            return result
        } else {
            return nil
        }
    }
    
    func removeImage(id: String) {
        guard let folderPath = getFolderPath() else { return }
        
        let imageName = "\(id).jpg"
        let fileURL = folderPath.appendingPathComponent(imageName, conformingTo: .jpeg)
        
        if fileManager.fileExists(atPath: fileURL.path()) {
            do {
                try fileManager.removeItem(atPath: fileURL.path())
            } catch {
                print("file remove error", error)
            }
            
        } else {
            print("file no exist")
        }
        
    }
}
