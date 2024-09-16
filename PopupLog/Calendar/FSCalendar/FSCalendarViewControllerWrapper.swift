//
//  FSCalendarViewControllerWrapper.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import UIKit
import SwiftUI
import Combine
import FSCalendar
import SnapKit

struct FSCalendarViewControllerWrapper: UIViewControllerRepresentable {
    @ObservedObject var vm: CalendarViewModel
    @Binding var detent: PresentationDetent

    func makeUIViewController(context: Context) -> some UIViewController {
        FSCalendarViewController(vm: vm)
    }
    
    // BottomSheet 높이 변할 때마다 달력의 형태도 변경 
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard let vc = uiViewController as? FSCalendarViewController else { return }
        guard let detentType = Detents.allCases.filter({ $0.detents == detent }).first else { return }
        vc.changeScopeByDetent(detentType)
    }
    
    class FSCalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
        init(vm: CalendarViewModel) {
            super.init(nibName: nil, bundle: nil)
            self.vm = vm
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var vm: CalendarViewModel!
        private var subscriptions = Set<AnyCancellable>()
        
        private lazy var calendar: FSCalendar = {
            let calendar = FSCalendar()
            calendar.delegate = self
            calendar.dataSource = self
            calendar.register(CalendarCell.self, forCellReuseIdentifier: CalendarCell.identifier)
            
            calendar.headerHeight = 0
            calendar.appearance.borderRadius = 0.5
            calendar.appearance.headerMinimumDissolvedAlpha = 0.0
            calendar.appearance.caseOptions = .weekdayUsesSingleUpperCase
            
            calendar.appearance.titleFont = Resources.Fonts.bold15
            calendar.appearance.weekdayFont = Resources.Fonts.regular14
            
            calendar.appearance.titleSelectionColor = UIColor(Resources.Colors.white)
            calendar.appearance.todayColor = Resources.Colors.primaryColorUK
            calendar.appearance.selectionColor = Resources.Colors.primaryColorUK
            calendar.appearance.weekdayTextColor = UIColor(Resources.Colors.black)
            return calendar
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupHierarchy()
            setupConstraints()
        }
        
        private func setupHierarchy() {
            view.addSubview(calendar)
        }
        
        private func setupConstraints() {
            calendar.snp.makeConstraints { make in
                make.edges.equalTo(view.safeAreaLayoutGuide)
            }
        }
        
        // BottomSheet에 따른 달력 모드 변경(mid -> 월간, large -> 주간)
        func changeScopeByDetent(_ data: Detents) {
            calendar.scope = data == .mid ? .month : .week
        }
        
        // MARK: FSCalendar Extension
        func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
            guard let cell = calendar.dequeueReusableCell(withIdentifier: CalendarCell.identifier, for: date, at: position) as? CalendarCell else { return FSCalendarCell() }
            return cell
        }
        
        // 날짜 페이지 변경됐을 때
        func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
            vm.action(.changeCurrentPage(date: calendar.currentPage))
        }
        
        // 날짜 탭할 때
        func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            calendar.today = date
            vm.action(.todayDate(date: date))
            // 선택한 날짜에 맞는 페이지로 이동
            calendar.setCurrentPage(date, animated: true)
            return true
        }
        
        // 주간모드에서 이전 또는 미래 날짜를 선택한 이후, 다시 월간모드로 돌아갔을 때
        // 사용자에게 보여주는 날짜 영역 데이터 업데이트
        func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
            let detent = Detents.allCases[Int(calendar.scope.rawValue)]
            guard detent == .mid else { return }
            vm.action(.changeCurrentPage(date: calendar.currentPage))
        }
    }
}

