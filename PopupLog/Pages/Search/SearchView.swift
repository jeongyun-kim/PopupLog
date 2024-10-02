//
//  SearchView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI
import RealmSwift

struct SearchView: View {
    @ObservedResults(Log.self) private var logList
    @EnvironmentObject private var viewStatus: CalendarViewStatus
    @EnvironmentObject private var stack: ViewPath
    @StateObject private var vm = SearchViewModel()
    private var searchResults: Results<Log> {
        if vm.output.keyword.isEmpty {
            return logList
        } else{
            return logList.where { log in
                log.title.contains(vm.output.keyword)
            }
        }
    }
    
    var body: some View {
        VStack {
            searchTextField()
                .padding()
            ZStack {
                searchListView()
                // 검색결과 없을 때
                if searchResults.isEmpty {
                    // - 키워드 X / 키워드 O 상황으로 나뉨
                    emptySearchView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Resources.Colors.moreLightOrange)
        .navigationTitle("기록 검색")
        .toolbarRole(.editor)
        .fullScreenCover(isPresented: $vm.output.isPresentingDetailView) {
            LazyNavigationView(DetailView(selectedLog: vm.output.selectedLog))
        }
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
            TextField("기록을 검색해보세요", text: $vm.output.keyword)
                .padding(.horizontal)
                .changedString($vm.output.keyword) {
                    vm.action(.changedKeyword)
                }
        }
    }
    
    // MARK: 검색결과 있을 때, 검색결과 리스트
    private func searchListView() -> some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(searchResults, id: \.id) { value in
                        TicketRowView(width: proxy.size.width, item: value, isBottomSheet: false)
                            .onTapGesture {
                                vm.action(.selectedLog(log: value))
                                vm.action(.toggleDetailView)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: 검색결과 없을 때
    private func emptySearchView() -> some View {
        VStack {
            Spacer()
            Text(vm.output.emptyText)
                .lineLimit(2)
                .foregroundStyle(Resources.Colors.lightGray)
            Spacer()
            Spacer()
        }
    }
}
