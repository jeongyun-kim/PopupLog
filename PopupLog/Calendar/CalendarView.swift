//
//  CalendarView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI

struct CalendarView: View {
    @StateObject var vm = CalendarViewModel()
    @State private var detentType: PresentationDetent = Resources.Detents.mid.detents
    @State private var isPresentingSheet = true
    @State private var isPresentingSideMenu = false
    
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
                    isPresentingSheet = !isPresentingSideMenu
                }
            }
            .navigationDestination(isPresented: .constant(vm.output.tappedMenuIdx == 0), destination: {
                LazyNavigationView(SearchView(isPresentingSideMenu: $isPresentingSideMenu))
            })
            .navigationDestination(isPresented: .constant(vm.output.tappedMenuIdx == 1), destination: {
                LazyNavigationView(SettingView(isPresentingSideMenu: $isPresentingSideMenu))
            })
            .onAppear {
                vm.action(.viewOnAppear)
                vm.action(.sideMenuRowTappedIdx(idx: -1))
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
            trailingBarButton(AnyView(ChartView(isPresentingSheet: $isPresentingSheet)), image: Resources.Images.chart)
            trailingBarButton(AnyView(AddView(isPresentingSheet: $isPresentingSheet)), image: Resources.Images.plus)
        }
    }
    
    private func trailingBarButton(_ view: AnyView, image: Image) -> some View {
        return NavigationLink(destination: {
            LazyNavigationView(view)
        }, label: {
            image
        })
        .padding(8)
        .disabled(!isPresentingSheet)
    }
    
    private func leadingBarButton() -> some View {
        Button(action: {
            isPresentingSideMenu.toggle()
            isPresentingSheet = !isPresentingSideMenu
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
                .sheet(isPresented: $isPresentingSheet, content: {
                    BottomSheetView()
                        .presentationDetents([Resources.Detents.mid.detents, Resources.Detents.large.detents], selection: $detentType)
                        .presentationBackgroundInteraction(.enabled)
                        .presentationDragIndicator(.hidden)
                        .presentationCornerRadius(Resources.Radius.bottomSheet)
                        .interactiveDismissDisabled()
                })
        }
    }
}
#Preview {
    CalendarView()
}
