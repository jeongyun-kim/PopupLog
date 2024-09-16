//
//  AddView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI

struct AddView: View {
    @Binding var isPresentingSheet: Bool
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                isPresentingSheet.toggle()
            }
    }
}

#Preview {
    AddView(isPresentingSheet: .constant(true))
}
