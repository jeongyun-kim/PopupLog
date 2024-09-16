//
//  MenuContentsView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI

struct MenuContentsView: View {
    // 사이드메뉴의 표출 여부
    @Binding var isPresenting: Bool
    @ObservedObject var vm: CalendarViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                logView()
                ForEach(Array(Menus.allCases.enumerated()), id: \.element.rawValue) { value in
                    rowView(value.element)
                        .onTapGesture {
                            vm.action(.rowTapped(idx: value.offset))
                        }
                }
                Spacer()
            }
            .padding(.top, 80)
            .padding(32)
            .frame(maxHeight: .infinity)
            .background(.white)
            Spacer()
        }
        .background(.clear)
    }
    
    // 기록한 팝업 개수 표출
    private func logView() -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text(Resources.Texts.record.rawValue)
                .font(.title3)
                .foregroundStyle(Resources.Colors.lightGray)
                .bold()
            Text("5개")
                .font(.title2)
                .bold()
                .foregroundStyle(Resources.Colors.black)
        }
        .padding(.vertical, 24)
    }
    
    // 페이지 이동 버튼
    private func rowView(_ item: Menus) -> some View {
        HStack(spacing: 16) {
            item.image
                .resizable()
                .frame(width: 26, height: 26)
            Text(item.title)
                .bold()
        }
        .padding(.vertical)
        .padding(.trailing, 100)
        .foregroundStyle(.black)
    }
    
    private enum Menus: Int, CaseIterable {
        case search = 0
        case setting
        
        var title: String {
            switch self {
            case .search:
                return "검색"
            case .setting:
                return "설정"
            }
        }
        
        var image: Image {
            switch self {
            case .search:
                return Resources.Images.search
            case .setting:
                return Resources.Images.setting
            }
        }
    }
}

#Preview {
    MenuContentsView(isPresenting: .constant(true), vm: CalendarViewModel())
}
