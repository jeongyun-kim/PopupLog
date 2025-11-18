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
    @Environment(\.openURL) var openURL
    private let email = SupportEmail(email: BundleWrapper(.email).wrappedValue, title: "건의하기")
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                logView()
                menuListView()
                Spacer()
                Spacer()
                emailAndVersionView()
                Spacer()
                Spacer()
            }
            .padding(.top, 90)
            .padding(.leading, 20)
            .padding(.trailing, 32)
            .frame(maxHeight: .infinity)
            .background(Resources.Colors.white)
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
        case filter
        
        var title: String {
            switch self {
            case .search:
                return "검색"
            case .setting:
                return "태그 관리"
            case .filter:
                return "태그별 모아보기"
            }
        }
        
        var image: Image {
            switch self {
            case .search:
                return Resources.Images.search
            case .setting:
                return Resources.Images.tagSetting
            case .filter:
                return Resources.Images.hashTag
            }
        }
    }
}

// MARK: ViewUI
extension MenuContentsView {
    // MARK: 메뉴 리스트
    private func menuListView() -> some View {
        ForEach(Array(Menus.allCases.enumerated()), id: \.element.rawValue) { value in
            Button(action: {
                let viewType = StackViewType.allCases[value.offset]
                stack.path.append(viewType)
            }, label: {
                rowView(value.element)
            })
        }
    }
    
    // MARK: 기록한 팝업 개수 표출
    private func logView() -> some View {
        let logCnt = logList.count > 999 ? "999+" : "\(logList.count)"
        return VStack(alignment: .center, spacing: 4) {
            Text("✨ 지금까지 \(logCnt)개의")
                .font(.callout)
                .foregroundStyle(Resources.Colors.lightGray)
            Text("기록을 남겼어요")
                .font(.callout)
                .foregroundStyle(Resources.Colors.lightGray)
        }
        .padding(.vertical, 24)
    }
    
    // MARK: 페이지 이동 버튼
    private func rowView(_ item: Menus) -> some View {
        HStack(spacing: 8) {
            item.image
                .resizable()
                .frame(width: 20, height: 20)
            Text(item.title)
                .font(.callout)
            Spacer()
        }
        .frame(width: 160)
        .padding(.vertical, 12)
        .foregroundStyle(Resources.Colors.black)
    }
    
    // MARK: 건의하기 + 버전 정보
    private func emailAndVersionView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                email.send(openURL: openURL)
            }, label: {
                Text("건의하기")
                    .font(.callout)
                    .foregroundStyle(Resources.Colors.lightGray)
            })
            Text("버전 1.5.2")
                .font(.caption)
                .foregroundStyle(Resources.Colors.lightGray)
        }
    }
}
