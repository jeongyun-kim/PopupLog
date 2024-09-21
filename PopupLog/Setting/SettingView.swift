//
//  SettingView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI

struct SettingView: View {
    @Binding var isPresentingSideMenu: Bool
    @Binding var isMainView: Bool
    @Binding var isPresentingSheet: Bool
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                isPresentingSideMenu = false
                isMainView = false
            }
            .onDisappear {
                isPresentingSheet = true
            }
            .toolbarRole(.editor)
    }
}
//
//#Preview {
//    SettingView(isPresentingSideMenu: .constant(true))
//}
