//
//  CalendarView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI
import RealmSwift

struct CalendarView: View {
    @EnvironmentObject private var stack: ViewPath
    @StateObject var vm = CalendarViewModel()
    @EnvironmentObject var viewStatus: CalendarViewStatus
    @State private var detentType: PresentationDetent = Resources.Detents.mid.detents
    
    var body: some View {
        NavigationStack(path: $stack.path) {
            ZStack {
                VStack(alignment: .leading, spacing: 8) {
                    currentYearMonth()
                    randomTitle()
                    calendarView()
                }
                SideMenuView(isPresenting: $viewStatus.isPresentingSideMenu,
                             content: AnyView(MenuContentsView(vm: vm)))
                .changedBool($viewStatus.isPresentingSideMenu) {
                    guard viewStatus.isMainView else { return }
                    viewStatus.isPresentingBottomSheet = !viewStatus.isPresentingSideMenu
                }
            }
            .navigationDestination(for: StackViewType.self, destination: { viewType in
                switch viewType {
                case .searchView:
                    LazyNavigationView(SearchView())
                case .tagSettingView:
                    LazyNavigationView(TagSettingView())
                }
            })
            .onAppear {
                vm.action(.viewOnAppear)
                viewStatus.isMainView = true
            }
            .navigationBar(leading: {
                leadingBarButton()
            }, trailing: {
                trailingBarButtons()
            })
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(Resources.Colors.primaryColor)
    }
}

// MARK: ViewUI
extension CalendarView {
    // MARK: 현재 보고있는 캘린더의 년월
    private func currentYearMonth() -> some View {
        Text(vm.output.currentYearMonth) // Output : 현재 페이지 날짜
            .font(.callout)
            .foregroundStyle(Resources.Colors.lightGray)
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 4)
    }
    
    // MARK: 랜덤 타이틀 멘트
    private func randomTitle() -> some View {
        Text(vm.output.randomTitle) // Output : 랜덤 제목
            .font(.title2)
            .foregroundStyle(Resources.Colors.black)
            .bold()
            .padding(.horizontal)
            .padding(.bottom, 8)
    }
    
    // MARK: 캘린더
    private func calendarView() -> some View {
        GeometryReader { proxy in
            FSCalendarViewControllerWrapper(vm: vm, detent: $detentType, reloadCalendar: $vm.output.reloadCalendarTrigger)
                .frame(height: proxy.size.width*0.9)
                .padding(.horizontal)
                .sheet(isPresented: $viewStatus.isPresentingBottomSheet, content: {
                    BottomSheetView(vm: vm)
                        .presentationDetents([Resources.Detents.mid.detents, Resources.Detents.large.detents], selection: $detentType)
                        .presentationBackgroundInteraction(.enabled)
                        .presentationDragIndicator(.hidden)
                        .presentationCornerRadius(Resources.Radius.bottomSheet)
                        .interactiveDismissDisabled()
                })
        }
    }
    
    // MARK: NavigationTrailing
    private func trailingBarButtons() -> some View {
        HStack(spacing: 0) {
//            NavigationLink {
//                LazyNavigationView(ChartView())
//            } label: {
//                Resources.Images.chart
//                    .padding(8)
//            }
//            .disabled(!viewStatus.isPresentingBottomSheet)
            NavigationLink {
                LazyNavigationView(AddOrEditView())
            } label: {
                Resources.Images.plus
                    .padding(8)
            }
            .disabled(!viewStatus.isPresentingBottomSheet)
        }
    }
    
    // MARK: NavigationLeading
    private func leadingBarButton() -> some View {
        Button(action: {
            viewStatus.isPresentingSideMenu.toggle()
            viewStatus.isPresentingBottomSheet = !viewStatus.isPresentingSideMenu
        }, label: {
            Resources.Images.menu
                .foregroundStyle(Resources.Colors.primaryColor)
        })
    }
}
