//
//  SettingView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI

struct SettingView: View {
    @Binding var isPresentingSideMenu: Bool
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                isPresentingSideMenu.toggle()
            }
    }
}

#Preview {
    SettingView(isPresentingSideMenu: .constant(true))
}