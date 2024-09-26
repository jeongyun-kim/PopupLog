//
//  PopupLogApp.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI
import RealmSwift

@main
struct PopupLogApp: App {
    var body: some Scene {
        WindowGroup {
    //        TagSettingView()
            CalendarView()
                .environmentObject(CalendarViewStatus())
                .environmentObject(ViewPath())
        }
    }
}

final class CalendarViewStatus: ObservableObject {
    @Published var isPresentingBottomSheet = true
    @Published var isPresentingSideMenu = false
    @Published var isMainView = true
}

final class ViewPath: ObservableObject {
    @Published var path: [StackViewType] = []
}
