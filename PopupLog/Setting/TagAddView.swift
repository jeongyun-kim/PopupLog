//
//  TagAddView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/22/24.
//

import SwiftUI
import RealmSwift
import MCEmojiPicker

struct TagAddView: View {
    @ObservedResults (Tag.self) private var tagList
    @Environment(\.dismiss) private var dismiss
    @State private var emoji: String = "😊"
    @State private var tagName = ""
    @State private var isPresenting = false
    @State private var tagColor: Color = Resources.Colors.systemGray6
    @EnvironmentObject var isPresentingSheet: CalendarViewSheetPresent
    
    
    private let deinitDetector = DeinitDetector<Self>() {
            // deinit 시 하고싶은 일들~
        print("tag add view deinit")
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button(emoji) {
                        isPresenting.toggle()
                    }.emojiPicker(
                        isPresented: $isPresenting,
                        selectedEmoji: $emoji
                    )
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
                
                HStack {
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
                    Spacer()
                }
                
                VStack {
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    self.endTextEditing()
                }
                
                
            }
            .padding()
        }
   
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Resources.Colors.moreLightOrange)
        .navigationTitle("태그 생성")
        .navigationBar(leading: {}, trailing: {
            Button(action: {
                let tagColor = tagColor.toHex()
                let tag = Tag(emoji: emoji, tagName: tagName, tagColor: tagColor, isDefault: false)
                $tagList.append(tag)
                dismiss()
            }) {
                Text("저장")
            }
        })
        .toolbarRole(.editor)
        .onAppear {
            isPresentingSheet.isPresenting = false
        }
    }
}
