//
//  CalendarView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI

struct CalendarView: View {
    @StateObject var vm = CalendarViewModel()
    @EnvironmentObject var bottomSheetPresenting: CalendarViewSheetPresent
    @State private var detentType: PresentationDetent = Resources.Detents.mid.detents
    @State private var isPresentingSideMenu = false
    @State private var isMainView = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 8) {
                    currentYearMonth()
                    randomTitle()
                    calendarView()
                }
                SideMenuView(isPresenting: $isPresentingSideMenu,
                             content: AnyView(MenuContentsView(isPresenting: $isPresentingSideMenu, vm: vm)))
                .changedBool($isPresentingSideMenu) {
                    guard isMainView else { return }
                    bottomSheetPresenting.isPresenting = !isPresentingSideMenu
                }
            }
            .navigationDestination(isPresented: .constant(vm.output.tappedMenuIdx == 0), destination: {
                LazyNavigationView(SearchView(isPresentingSideMenu: $isPresentingSideMenu, isMainView: $isMainView))
            })
            .navigationDestination(isPresented: .constant(vm.output.tappedMenuIdx == 1), destination: {
                LazyNavigationView(SettingView(isPresentingSideMenu: $isPresentingSideMenu, isMainView: $isMainView))
            })
            .onAppear {
                vm.action(.viewOnAppear)
                isMainView = true
            }
            .navigationBar(leading: {
                leadingBarButton()
            }, trailing: {
                trailingBarButtons()
            })
        }
        .tint(Resources.Colors.primaryColor)
    }
}

// MARK: NavigationBarButton
extension CalendarView {
    private func trailingBarButtons() -> some View {
        HStack(spacing: 0) {
            trailingBarButton(AnyView(ChartView(isPresentingSheet: $bottomSheetPresenting.isPresenting)), image: Resources.Images.chart)
            trailingBarButton(AnyView(AddOrEditView()), image: Resources.Images.plus)
        }
    }
    
    private func trailingBarButton(_ view: AnyView, image: Image) -> some View {
        return NavigationLink(destination: {
            LazyNavigationView(view)
        }, label: {
            image
        })
        .padding(8)
        .disabled(!bottomSheetPresenting.isPresenting)
    }
    
    private func leadingBarButton() -> some View {
        Button(action: {
            isPresentingSideMenu.toggle()
            bottomSheetPresenting.isPresenting = !isPresentingSideMenu
        }, label: {
            Resources.Images.menu
                .foregroundStyle(Resources.Colors.primaryColor)
        })
    }
}

// MARK: ViewUI
extension CalendarView {
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
            .foregroundStyle(Resources.Colors.black)
            .bold()
            .padding(.horizontal)
            .padding(.bottom, 8)
    }
    
    private func calendarView() -> some View {
        GeometryReader { proxy in
            FSCalendarViewControllerWrapper(vm: vm, detent: $detentType)
                .frame(height: proxy.size.width*0.9)
                .padding(.horizontal)
                .sheet(isPresented: $bottomSheetPresenting.isPresenting, content: {
                    BottomSheetView(vm: vm)
                        .presentationDetents([Resources.Detents.mid.detents, Resources.Detents.large.detents], selection: $detentType)
                        .presentationBackgroundInteraction(.enabled)
                        .presentationDragIndicator(.hidden)
                        .presentationCornerRadius(Resources.Radius.bottomSheet)
                        .interactiveDismissDisabled()
                })
        }
    }
}

//#Preview {
//    CalendarView()
//}
