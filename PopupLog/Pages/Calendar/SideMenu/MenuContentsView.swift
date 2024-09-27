//
//  MenuContentsView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI
import RealmSwift

struct MenuContentsView: View {
    @EnvironmentObject private var stack: ViewPath
    @ObservedResults(Log.self) private var logList
    @ObservedObject var vm: CalendarViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                logView()
                menuListView()
                Spacer()
            }
            .padding(.top, 90)
            .padding(.leading, 20)
            .padding(.trailing, 32)
            .frame(maxHeight: .infinity)
            .background(.white)
            Spacer()
        }
        .background(.clear)
    }
}

// MARK: MenuCase 정의
extension MenuContentsView {
    private enum Menus: Int, CaseIterable {
        case search = 0
        case setting
        
        var title: String {
            switch self {
            case .search:
                return "검색"
            case .setting:
                return "태그 관리"
            }
        }
        
        var image: Image {
            switch self {
            case .search:
                return Resources.Images.search
            case .setting:
                return Resources.Images.tagSetting
            }
        }
    }
}

// MARK: ViewUI
extension MenuContentsView {
    // 메뉴 리스트
    private func menuListView() -> some View {
        ForEach(Array(Menus.allCases.enumerated()), id: \.element.rawValue) { value in
            Button(action: {
                let viewType = StackViewType.allCases[value.offset]
                switch viewType {
                case .searchView:
                    stack.path.append(.searchView)
                case .tagSettingView:
                    stack.path.append(.tagSettingView)
                }
            }, label: {
                rowView(value.element)
            })
        }
    }
    
    // 기록한 팝업 개수 표출
    private func logView() -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text("✨ 지금까지 \(logList.count)개의")
                .font(.callout)
                .foregroundStyle(Resources.Colors.lightGray)
                .lineLimit(2)
            
            Text("기록을 남겼어요")
                .font(.callout)
                .foregroundStyle(Resources.Colors.lightGray)
        }
        .padding(.vertical, 24)
    }
    
    // 페이지 이동 버튼
    private func rowView(_ item: Menus) -> some View {
        HStack(spacing: 8) {
            item.image
                .resizable()
                .frame(width: 20, height: 20)
            Text(item.title)
                .font(.callout)
            Spacer()
        }
        .frame(width: 130)
        .padding(.vertical, 12)
        .foregroundStyle(.black)
    }
}
