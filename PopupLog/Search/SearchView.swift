//
//  SearchView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI
import RealmSwift

struct SearchView: View {
    private enum EmptyViewKeyword: String {
        case emptyKeyword = "🔍 제목을 통해 지금까지 \n저장한 기록들을 찾아보세요"
        case noResults = "🥲 검색결과가 없어요"
    }
    
    @EnvironmentObject var viewStatus: CalendarViewStatus
    @State private var searchList: [Log] = []
    @State private var keyword = ""
    @State private var emptyText = EmptyViewKeyword.emptyKeyword.rawValue
    
    var body: some View {
        VStack {
            searchTextField()
            ZStack {
                searchListView()
                if searchList.isEmpty {
                    emptySearchView()
                }
                
            }
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Resources.Colors.moreLightOrange)
        .navigationTitle("기록 검색")
        .toolbarRole(.editor)
        .onAppear {
            viewStatus.isPresentingSideMenu = false
            viewStatus.isMainView = false
        }
        .onDisappear {
            viewStatus.isPresentingBottomSheet = true
        }
        .onTapGesture {
            self.endTextEditing()
        }
    }
}

// MARK: ViewUI
extension SearchView {
    // MARK: 검색 텍스트필드
    private func searchTextField() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Resources.Radius.textContents)
                .fill(Resources.Colors.white)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
            TextField("기록을 검색해보세요", text: $keyword)
                .padding(.horizontal)
                .changedString($keyword) {
                    searchList = LogRepository.shared.getSearchedLogs(keyword)
                    emptyText = keyword.isEmpty ?
                    EmptyViewKeyword.emptyKeyword.rawValue : EmptyViewKeyword.noResults.rawValue
                }
        }
    }
    
    // MARK: 검색결과 있을 때, 검색결과 리스트
    private func searchListView() -> some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(searchList, id: \.id) { value in
                        TicketRowView(width: proxy.size.width, item: value, isBottomSheet: false)
                    }
                }
            }
        }
    }
    
    // MARK: 검색결과 없을 때
    private func emptySearchView() -> some View {
        VStack {
            Spacer()
            Text(emptyText)
                .lineLimit(2)
                .foregroundStyle(Resources.Colors.lightGray)
            Spacer()
            Spacer()
        }
    }
}
