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
                    logList.filter { $0.visitDate.formattedDate == vm.output.selectedDate }
                    , id: \.id
                ) { item in
                    TicketRowView(width: proxy.size.width, item: item)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Resources.Colors.lightOrange)
                        .onTapGesture {
                            vm.action(.selectLog(log: item))
                            vm.action(.toggleFullCover)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                vm.action(.deleteLogImage(id: "\(item.id)"))
                                $logList.remove(item)
                                vm.action(.reloadCalendarTrigger(reload: true))
                            } label: {
                                Text("삭제")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .background(Resources.Colors.lightOrange)
            .overlay { // 리스트에 부합하는 데이터 없을 때
                let data = logList.filter { $0.visitDate.formattedDate == vm.output.selectedDate }
                if data.isEmpty {
                    emptyListView()
                }
            }
        }
        .fullScreenCover(isPresented: $vm.output.isPresentingFullCover, content: {
            LazyNavigationView(DetailView(selectedLog: vm.output.selectedLog))
                .onDisappear {
                    vm.action(.reloadCalendarTrigger(reload: true))
                }
        })
        .padding(.top, 32)
        .background(Resources.Colors.lightOrange)
    }
}

extension BottomSheetView {
    private func emptyListView() -> some View {
        ZStack {
            Rectangle()
                .fill(Resources.Colors.lightOrange)
                .ignoresSafeArea()
            VStack(spacing: 8) {
                Text("선택한 날짜에 기록이 없어요")
                Text("상단의 +를 통해 기록을 추가해보세요")
            }
            .font(.callout)
            .foregroundStyle(Resources.Colors.primaryColor.opacity(0.9))
        }
    }
}
