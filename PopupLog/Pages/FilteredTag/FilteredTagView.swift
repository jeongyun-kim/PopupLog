//
//  FilteredTagView.swift
//  PopupLog
//
//  Created by 김정윤 on 11/18/24.
//

import SwiftUI

struct FilteredTagView: View {
    @StateObject private var vm = FilteredTagViewModel()
    private let allTag = Tag(emoji: "😊", tagName: "전체")
    
    var body: some View {
        VStack {
            tagListView()
            
            if vm.output.filteredLogList.isEmpty {
                emptyLogListView()
            } else {
                logListView()
            }
        }
        .fullScreenCover(isPresented: $vm.output.isPresentingDetailView) {
            LazyNavigationView(DetailView(selectedLog: vm.output.selectedLog))
        }
        .navigationTitle("태그별 모아보기 - \(vm.output.selectedTag.tagName)")
        .toolbarRole(.editor)
        .padding(.vertical)
        .background(Resources.Colors.moreLightOrange)
    }
}

// MARK: UI
extension FilteredTagView {
    // MARK: LogListView
    private func logListView() -> some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(vm.output.filteredLogList, id: \.id) { log in
                        TicketRowView(width: proxy.size.width, item: log, isBottomSheet: false)
                            .onTapGesture {
                                vm.action(.selectedLog(log: log))
                                vm.action(.toggleDetailView)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: EmptyLogListView
    private func emptyLogListView() -> some View {
        Text("해당 태그로 저장된 기록이 없어요")
            .foregroundStyle(Resources.Colors.lightGray)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: -50)
    }
    
    // MARK: TagListView
    private func tagListView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                TagView(tag: allTag)
                    .onTapGesture {
                        vm.action(.selectedTag(tag: allTag))
                    }
                ForEach(TagRepository.shared.getAllTags(), id: \.id) { tag in
                    TagView(tag: tag)
                        .onTapGesture {
                            vm.action(.selectedTag(tag: tag))
                        }
                }
            }
            .frame(height: 44)
            .padding(.horizontal)
        }
    }
}
