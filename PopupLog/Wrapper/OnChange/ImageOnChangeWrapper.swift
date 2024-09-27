//
//  ImageOnChangeWrapper.swift
//  PopupLog
//
//  Created by 김정윤 on 9/18/24.
//

import SwiftUI
import PhotosUI

// 사용자가 이미지를 선택하였을 때, 변경된 이미지 반환
struct ImageOnChangeWrapper: ViewModifier {
    @Binding var pickerItem: PhotosPickerItem?
    let action: (UIImage) -> Void
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .onChange(of: pickerItem) {
                    getUIImage(pickerItem) { image in
                        action(image)
                    }
                }
        } else {
            content
                .onChange(of: pickerItem, perform: { _ in
                    getUIImage(pickerItem) { image in
                        action(image)
                    }
                })
        }
    }
    
    private func getUIImage(_ pickerItem: PhotosPickerItem?, completionHandler: @escaping (UIImage) -> Void) {
        guard let pickerItem else { return }
        Task {
            if let imageData = try? await pickerItem.loadTransferable(type: Data.self) {
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        completionHandler(image)
                    }
                }
            }
            else {
                print("Failed Get UIImage")
            }
        }
    }
}

extension View {
    func changedImage(_ item: Binding<PhotosPickerItem?>, action: @escaping (UIImage) -> Void) -> some View {
        modifier(ImageOnChangeWrapper(pickerItem: item, action: action))
    }
}
