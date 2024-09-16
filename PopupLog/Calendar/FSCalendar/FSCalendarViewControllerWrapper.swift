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

    func makeUIViewController(context: Context) -> some UIViewController {
        FSCalendarViewController(vm: vm)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    
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
        
        func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
            guard let cell = calendar.dequeueReusableCell(withIdentifier: CalendarCell.identifier, for: date, at: position) as? CalendarCell else { return FSCalendarCell() }
            return cell
        }
    }
}

