//
//  BottomSheetView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI
import RealmSwift

struct BottomSheetView: View {
    @ObservedResults(Log.self) private var logList
    @ObservedObject var vm: CalendarViewModel
 
    var body: some View {
        GeometryReader { proxy in
            List {
                ForEach(
                    logList.filter { $0.visitDate.formatted(date: .numeric, time: .omitted) == vm.output.selectedDate }
                ) { item in
                    rowView(proxy.size.width, item: item)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Resources.Colors.lightOrange)
                        .onTapGesture {
                            vm.action(.selectLog(log: item))
                            vm.action(.toggleFullCover)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                vm.action(.deleteLog(log: item))
                            } label: {
                                Text("삭제")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .background(Resources.Colors.lightOrange)
            .overlay { // 리스트에 부합하는 데이터 없을 때
                let data = logList.filter { $0.visitDate.formatted(date: .numeric, time: .omitted) == vm.output.selectedDate }
                if data.isEmpty {
                    Rectangle()
                        .fill(Resources.Colors.lightOrange)
                        .ignoresSafeArea()
                }
            }
        }
        .fullScreenCover(isPresented: $vm.output.isPresentingFullCover, content: {
            LazyNavigationView(DetailView(selectedLog: vm.output.selectedLog))
        })
        .padding(.top, 32)
        .background(Resources.Colors.lightOrange)
    }
}

// MARK: ViewUI
extension BottomSheetView {
    // MARK: 행의 큰틀
    private func rowView(_ width: CGFloat, item: Log) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Resources.Radius.ticket)
                .fill(Resources.Colors.white)
            contentsView(width, item: item)
        }
        .frame(height: 140)
        .overlay {
            Circle()
                .fill(Resources.Colors.lightOrange)
                .frame(width: 20, height: 20)
                .offset(x: -width*0.11, y: -70)
            Circle()
                .fill(Resources.Colors.lightOrange)
                .frame(width: 20, height: 20)
                .offset(x: -width*0.11, y: 70)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: 행 내 콘텐츠
    private func contentsView(_ width: CGFloat, item: Log) -> some View {
        ZStack(alignment: .bottomTrailing) {
            HStack(alignment: .top, spacing: 8) {
                Image("ticketDefaultImage", bundle: nil)
                    .resizable()
                    .frame(maxWidth: width*0.35, maxHeight: .infinity)
                    .background(.gray)
                    .clipShape(
                        .rect(topLeadingRadius: Resources.Radius.ticket, bottomLeadingRadius: Resources.Radius.ticket, bottomTrailingRadius: 0, topTrailingRadius: 0)
                    )
                LazyVStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .lineLimit(1)
                        .font(.headline)
                        .bold()
                    Text(item.content)
                        .lineLimit(3)
                        .font(Resources.Fonts.font14)
                }
                .padding(.top)
                .padding(.trailing, 12)
            }
            HStack {
                Text(item.place?.title ?? "")
                    .font(.caption)
                    .foregroundStyle(Resources.Colors.lightGray)
                if let tag = item.tag, let tagColor = tag.tagColor {
                    TagButton(emoji: tag.emoji, tagName: tag.tagName, tagColor: tagColor, action: {})
                        .padding(.vertical, 8)
                        .padding(.trailing, 8)
                }
            }
        }
    }
}
