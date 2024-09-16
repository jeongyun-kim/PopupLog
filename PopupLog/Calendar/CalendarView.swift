//
//  CalendarView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI

struct CalendarView: View {
    @StateObject var vm = CalendarViewModel()
    @State private var detentType: PresentationDetent = Detents.mid.detents
    @State private var isPresentingSheet = true
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack(alignment: .leading, spacing: 8) {
                    currentYearMonth()
                    randomTitle()
                    calendarView(proxy.size.width)
                }
            }
            .onAppear {
                vm.action(.viewOnAppear)
            }
        }
    }
    
    private func currentYearMonth() -> some View {
        Text(vm.output.currentYearMonth) // Output : 현재 페이지 날짜
            .font(.callout)
            .foregroundStyle(Resources.Colors.lightGray)
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 4)
    }
    
    private func randomTitle() -> some View {
        Text(vm.output.randomTitle) // Output : 랜덤 제목 
            .font(.title2)
            .bold()
            .padding(.horizontal)
            .padding(.bottom, 8)
    }
    
    private func calendarView(_ width: CGFloat) -> some View {
        FSCalendarViewControllerWrapper(vm: vm, detent: $detentType)
            .frame(height: (width-32))
            .padding(.horizontal)
            .sheet(isPresented: $isPresentingSheet, content: {
                BottomSheetView()
                    .presentationDetents([Detents.mid.detents, Detents.large.detents], selection: $detentType)
                    .presentationBackgroundInteraction(.enabled)
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(Resources.Radius.bottomSheet)
                    .interactiveDismissDisabled()
            })
    }
}

#Preview {
    CalendarView()
}
