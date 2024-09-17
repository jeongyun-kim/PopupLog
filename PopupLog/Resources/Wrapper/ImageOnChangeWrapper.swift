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
    let action: (Image) -> Void
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .onChange(of: pickerItem) {
                    Task {
                        if let image = try? await pickerItem?.loadTransferable(type: Image.self) {
                            action(image)
                        } else {
                            print("Failed")
                        }
                    }
                }
        } else {
            content
                .onChange(of: pickerItem, perform: { _ in
                    Task {
                        if let image = try? await pickerItem?.loadTransferable(type: Image.self) {
                            action(image)
                        } else {
                            print("Failed")
                        }
                    }
                })
        }
    }
}

extension View {
    func changedImage(_ item: Binding<PhotosPickerItem?>, action: @escaping (Image) -> Void) -> some View {
        modifier(ImageOnChangeWrapper(pickerItem: item, action: action))
    }
}
