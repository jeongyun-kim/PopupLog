//
//  PopupLogApp.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI

@main
struct PopupLogApp: App {
    var body: some Scene {
        WindowGroup {
            CalendarView()
                .environmentObject(CalendarViewSheetPresent())
        }
    }
}

final class CalendarViewSheetPresent: ObservableObject {
    @Published var isPresenting = true
}
