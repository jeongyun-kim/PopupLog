//
//  TagSettingView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/22/24.
//

import SwiftUI
import RealmSwift

struct TagSettingView: View {
    @EnvironmentObject var viewStatus: CalendarViewStatus // 캘린더뷰 내 항목들
    @ObservedResults (Tag.self) private var tagList
    @State private var isPresenting = false // AddOrEditTagView 보여지고 있는지
    @State private var selectedTag = Tag() // 다음 뷰로 넘겨줄 태그
    
    var body: some View {
        ScrollView(showsIndicators: false, content: {
            VStack(alignment: .leading) {
                tagAddRowView()
                
                Text("기본 태그 목록")
                    .font(.caption)
                    .foregroundStyle(Resources.Colors.lightGray)
                    .padding(.horizontal, 24)
                defaultTagListView()
                
                Text("사용자 태그 목록")
                    .font(.caption)
                    .foregroundStyle(Resources.Colors.lightGray)
                    .padding(.horizontal, 24)
                    .padding(.top)
                nonDefaultTagListView()
            }
        })
        .background(Resources.Colors.moreLightOrange)
        .navigationTitle("태그 관리")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .onAppear {
            viewStatus.isPresentingSideMenu = false
            viewStatus.isMainView = false
        }
        .onDisappear {
            viewStatus.isPresentingBottomSheet = true
        }
        .sheet(isPresented: $isPresenting, content: {
            SheetTagView(tag: $selectedTag, isPresenting: $isPresenting)
        })
    }
}

struct SheetTagView: View {
    @Binding var tag: Tag
    @Binding var isPresenting: Bool
    
    var body: some View {
        LazyNavigationView(AddOrEditTagView(tag: tag))
    }
}

// MARK: ViewUI
extension TagSettingView {
    // MARK: 태그 생성
    private func tagAddRowView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Resources.Radius.textContents)
                .fill(Resources.Colors.white)
            Button {
                selectedTag = Tag()
                isPresenting.toggle()
            } label: {
                HStack {
                    Text("태그 생성")
                        .foregroundStyle(Resources.Colors.black)
                        .padding()
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
    
    // MARK: 기본 태그 리스트
    private func defaultTagListView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Resources.Radius.textContents)
                .fill(Resources.Colors.white)
            LazyVStack(alignment: .leading) {
                ForEach(tagList.filter { $0.isDefault }, id: \.id) { tag in
                    HStack {
                        TagView(tag: tag)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(4)
                }
            }
            .padding(8)
        }
        .padding(.horizontal)
    }
    
    // MARK: 사용자 태그 리스트
    private func nonDefaultTagListView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Resources.Radius.textContents)
                .fill(Resources.Colors.white)
                .overlay {
                    if tagList.filter({ !$0.isDefault }).isEmpty {
                        RoundedRectangle(cornerRadius: Resources.Radius.textContents)
                            .fill(Resources.Colors.moreLightOrange)
                    }
                }
            LazyVStack {
                ForEach(tagList.filter { !$0.isDefault }, id: \.id) { tag in
                    Button {
                        selectedTag = tag
                        isPresenting.toggle()
                    } label: {
                        HStack {
                            TagView(tag: tag)
                            Spacer()
                            Resources.Images.next
                                .foregroundStyle(Resources.Colors.lightGray)
                        }
                        .padding(4)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(8)
        }
        .padding(.horizontal)
    }
}
