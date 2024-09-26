//
//  SearchView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var viewStatus: CalendarViewStatus
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                viewStatus.isPresentingSideMenu = false
                viewStatus.isMainView = false
            }
            .onDisappear {
                viewStatus.isPresentingBottomSheet = true
            }
            .toolbarRole(.editor)
    }
}
