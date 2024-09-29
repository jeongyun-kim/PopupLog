//
//  AddOrEditTagView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/22/24.
//

import SwiftUI
import RealmSwift
import MCEmojiPicker

struct AddOrEditTagView: View {
    @ObservedResults (Tag.self) private var tagList // 태그 DB
    @ObservedRealmObject var tagForEdit: Tag = Tag() // 편집할 태그
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEmoji: String = "😊" // 사용자 선택 이모지
    @State private var tagName = "" // 보여질 태그명
    @State private var tagColor: Color = Resources.Colors.systemGray6 // 보여질 태그 컬러
    @State private var isPresentingEmojiView = false // emoji picker presenting
    private var isEditMode = false
    
    init(tag: Tag? = nil) {
        // 만약 수정할 태그를 가지고 온다면 
        if let tag, let color = tag.tagColor {
            tagForEdit = tag
            self._selectedEmoji = State(initialValue: tag.emoji)
            self._tagName = State(initialValue: tag.tagName)
            self._tagColor = State(initialValue: Color.init(hex: color))
            isEditMode.toggle()
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        emojiView()
                        tagNameTextField()
                    }
                    HStack {
                        colorPickerView()
                        Spacer()
                    }
                    spacerView()
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Resources.Colors.moreLightOrange)
            .navigationTitle(isEditMode == false ? "태그 생성" : "태그 편집")
            .navigationBar(leading: {
                leadingButton()
            }, trailing: {
                trailingButtons()
            })
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Tag 편집
    func editTag(_ tagColor: String?) {
        $tagForEdit.tagName.wrappedValue = tagName
        $tagForEdit.emoji.wrappedValue = selectedEmoji
        $tagForEdit.tagColor.wrappedValue = tagColor
    }
    
    // Tag 저장
    func saveTag(_ tagColor: String?) {
        tagForEdit.tagName = tagName
        tagForEdit.emoji = selectedEmoji
        tagForEdit.tagColor = tagColor
        tagForEdit.isDefault = false
        $tagList.append(tagForEdit)
    }
}

// MARK: ViewUI
extension AddOrEditTagView {
    // MARK: 이모지
    private func emojiView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Resources.Radius.textContents)
                .fill(Resources.Colors.white)
                .frame(width: 56, height: 56)
            Button(selectedEmoji) {
                isPresentingEmojiView.toggle()
            }.emojiPicker(
                isPresented: $isPresentingEmojiView,
                selectedEmoji: $selectedEmoji
            )
            .font(.title)
        }
    }
    
    // MARK: 태그명
    private func tagNameTextField() -> some View {
        TextField("등록할 태그명을 입력해주세요", text: $tagName)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .padding(.horizontal)
            .disabled(tagName.count > 10)
            .autocorrectionDisabled()
            .tint(Resources.Colors.primaryColor)
            .background(Resources.Colors.white)
            .clipShape(RoundedRectangle(cornerRadius: Resources.Radius.textContents))
    }
    
    // MARK: 태그 색상
    private func colorPickerView() -> some View {
        ColorPicker(selection: $tagColor) {
            ZStack {
                RoundedRectangle(cornerRadius: Resources.Radius.textContents)
                    .fill(tagColor)
                    .frame(height: 56)
                Text("태그 색상을 지정해보세요")
                    .padding(8)
                    .onTapGesture {
                        self.endTextEditing()
                    }
            }
        }
    }
    
    // MARK: 키보드 내리기 위한 빈뷰
    private func spacerView() -> some View {
        VStack {
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            self.endTextEditing()
        }
    }
    
    // MARK: NavigationTrailing
    private func trailingButtons() -> some View {
        HStack {
            if isEditMode {
                Button(action: {
                    $tagList.remove(tagForEdit)
                    dismiss()
                }, label: {
                    Text("삭제")
                })
            }
            Button(action: {
                let tagColor = tagColor.toHex()
                isEditMode == false ? saveTag(tagColor) : editTag(tagColor)
                dismiss()
            }) {
                Text("저장")
            }
            .disabled(tagName.isEmptyRemovedSpace)
        }
    }
    
    // MARK: NavigationLeading
    private func leadingButton() -> some View {
        Button(action: {
            dismiss()
        }, label: {
            Text("취소")
        })
    }
}
