//
//  SideMenuView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isPresenting: Bool
    var content: AnyView
    
    var body: some View {
            ZStack{
                if isPresenting {
                    Color.black
                        .opacity(0.3)
                        .onTapGesture {
                            isPresenting.toggle()
                        }
                    content
                        .transition(.move(edge: .leading))
                        .background(.clear)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
            .animation(.easeInOut, value: isPresenting)
    }
}

