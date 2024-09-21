//
//  BottomSheetView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI

struct BottomSheetView: View {
    @ObservedObject var vm: CalendarViewModel
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVStack(spacing: 30) {
                    ForEach(vm.output.logList, id: \.id) { item in
                        ZStack {
                            RoundedRectangle(cornerRadius: Resources.Radius.ticket)
                                .fill(Resources.Colors.white)
                            contentsView(proxy.size.width, item: item)
                        }
                        .frame(height: 140)
                        .overlay {
                            Circle()
                                .fill(Resources.Colors.lightOrange)
                                .frame(width: 20, height: 20)
                                .offset(x: -proxy.size.width*0.11, y: -70)
                            Circle()
                                .fill(Resources.Colors.lightOrange)
                                .frame(width: 20, height: 20)
                                .offset(x: -proxy.size.width*0.11, y: 70)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 32)
        .background(Resources.Colors.lightOrange)
    }

    private func contentsView(_ width: CGFloat, item: Log) -> some View {
        ZStack(alignment: .bottomTrailing) {
            HStack(spacing: 8) {
                Image("logo", bundle: nil)
                    .resizable()
                    .frame(maxWidth: width*0.35, maxHeight: .infinity)
                    .background(.gray)
                    .clipShape(
                        .rect(topLeadingRadius: Resources.Radius.ticket, bottomLeadingRadius: Resources.Radius.ticket, bottomTrailingRadius: 0, topTrailingRadius: 0)
                    )
                LazyVStack(alignment: .leading, spacing: 6) {
                    Text(item.content)
                        .lineLimit(3)
                        .font(Resources.Fonts.font14)
                    Text(item.place?.title ?? "")
                        .font(.caption)
                        .foregroundStyle(Resources.Colors.lightGray)
                }
                .padding(.top, 8)
                .padding(.trailing, 12)
            }
            if let tag = item.tag, let tagColor = tag.tagColor {
                TagButton(emoji: tag.emoji, tagName: tag.tagName, tagColor: tagColor, action: {})
                    .padding(.bottom, 8)
                    .padding(.trailing, 8)
            }
        }
    }
}
