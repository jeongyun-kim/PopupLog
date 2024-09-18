//
//  AddView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI
import PhotosUI

struct AddView: View {
    @Binding var isPresentingSheet: Bool
    @State private var titleField = ""
    @State private var contentField = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var image: Image = Resources.Images.plus
    @State private var visitedDate = Date()
    @State private var place = ""
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ZStack(alignment: .center) {
                        PhotosPicker(selection: $selectedPhoto) {
                            RoundedRectangle(cornerRadius: Resources.Radius.image)
                                .fill(Resources.Colors.lightOrange)
                                .foregroundStyle(Resources.Colors.primaryColor)
                                .padding()
                                .frame(width: proxy.size.width,
                                       height: proxy.size.width*0.75)
                                .overlay {
                                    photoPickerImageView()
                                }
                        }
                        .changedImage($selectedPhoto) { value in
                            image = value
                        }
                    }
                    .padding(.top)
                    popupInfoView()
                    titleView()
                    tagView()
                    contentsView()
                }
            }
        }
        .onAppear {
            isPresentingSheet.toggle()
        }
        .navigationBar {
            
        } trailing: {
            Button(action: {}, label: {
                Text("저장")
            })
        }
        .navigationTitle("기록하기")
        .toolbarRole(.editor)
        
    }
}

extension AddView {
    // MARK: 본문
    private func contentsView() -> some View {
        VStack(alignment: .leading) {
            Text("본문")
                .font(.headline)
            ZStack(alignment: .leading) {
                if contentField.isEmpty {
                    VStack {
                        Text("내용을 입력해주세요")
                            .foregroundStyle(Resources.Colors.lightGray)
                            .padding()
                        Spacer()
                    }
                }
                TextEditor(text: $contentField)
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .opacity(contentField.isEmpty ? 0.3 : 1)
                    .padding(8)
                    .overlay {
                        RoundedRectangle(cornerRadius: Resources.Radius.textContents)
                            .strokeBorder(lineWidth: 1)
                            .foregroundStyle(Resources.Colors.lightGray)
                    }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: 태그
    private func tagView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("태그")
                    .font(.headline)
                // 선택된 태그
                TagButton(emoji: "⭐️", tagName: "선택된 태그") {
                    print("tap")
                }
            }
            
            HStack {
                // 사용자가 생성한 태그 리스트
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(0..<10) { _ in
                            TagButton(emoji: "💖", tagName: "하트") {
                                print("heart")
                            }
                        }
                    }
                }
                Button(action: {
                    // sheet 이용해 태그리스트 띄우기
                }, label: {
                    Text("모두 보기")
                        .font(.callout)
                        .foregroundStyle(Resources.Colors.lightGray)
                })
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: 제목
    private func titleView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("제목")
                .padding(.horizontal)
                .font(.headline)
            
            TextField("제목을 입력해주세요", text: $titleField)
                .asRoundedTextField()
        }
        .padding(.bottom, 8)
    }
    
    // MARK: 방문일 & 팝업검색
    private func popupInfoView() -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 40) {
                HStack(spacing: 0) {
                    Text("방문일")
                        .font(.callout)
                        .bold()
                    DatePicker("", selection: $visitedDate, displayedComponents: .date)
                        .tint(Resources.Colors.primaryColor)
                }
                Spacer()
                searchPopupButton()
            }
            .offset(y: -16)
            HStack {
                Text("장소")
                    .font(.headline)
                ZStack(alignment: .leading) {
                    Text("장소를 검색해주세요") // 검색 장소
                        .foregroundStyle(Resources.Colors.lightGray)
                        .opacity(place.isEmpty ? 1 : 0)
                    Text(place) // 검색 장소 결과 주소
                        .font(.callout)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 6)
    }
    
    private func searchPopupButton() -> some View {
        Button(action: {}, label: {
            HStack(spacing: 4) {
                Resources.Images.search
                Text("장소 검색")
                    .font(.callout)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 6)
            .foregroundStyle(Resources.Colors.black)
            .background(Resources.Colors.systemGray6)
            .clipShape(.rect(cornerRadius: Resources.Radius.button))
        })
    }
    
    // MARK: 사진
    private func photoPickerImageView() -> some View {
        RoundedRectangle(cornerRadius: Resources.Radius.textContents)
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [8]))
            .opacity(image == Resources.Images.plus ? 1 : 0)
            .overlay {
                if image == Resources.Images.plus {
                    emptyImageView()
                } else {
                    // 사용자가 이미지를 선택한 경우
                    nonEmptyImageView()
                }
            }
            .foregroundStyle(Resources.Colors.primaryColor)
            .padding()
    }
    
    private func nonEmptyImageView() -> some View {
        ZStack(alignment: .topTrailing) {
            image // 사용자 선택 이미지
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: Resources.Radius.image))
            // 변경한 사진 제거
            Button(action: {
                image = Resources.Images.plus
            }, label: {
                Resources.Images.xmark
                    .resizable()
                    .padding()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(Resources.Colors.lightGray)
            })
        }
    }
    
    private func emptyImageView() -> some View {
        VStack(spacing: 4) {
            Resources.Images.plus
            Text("사진 추가")
        }
        .padding(.top)
    }
}

#Preview {
    AddView(isPresentingSheet: .constant(true))
}
