//
//  TicketRowView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/27/24.
//

import SwiftUI

struct TicketRowView: View {
    let width: CGFloat
    let item: Log
    let isBottomSheet: Bool
    
    init(width: CGFloat, item: Log, isBottomSheet: Bool = true) {
        self.width = width
        self.item = item
        self.isBottomSheet = isBottomSheet
    }
    
    var body: some View {
        rowView(width, item: item, isBottomSheet: isBottomSheet)
    }
    
    // MARK: 행의 큰틀
    private func rowView(_ width: CGFloat, item: Log, isBottomSheet: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Resources.Radius.ticket)
                .fill(Resources.Colors.white)
            contentsView(width, item: item)
        }
        .frame(height: 140)
        .overlay {
            Circle()
                .fill(isBottomSheet ? Resources.Colors.lightOrange : Resources.Colors.moreLightOrange)
                .frame(width: 20, height: 20)
                .offset(x: -width*0.11, y: -70)
            Circle()
                .fill(isBottomSheet ? Resources.Colors.lightOrange : Resources.Colors.moreLightOrange)
                .frame(width: 20, height: 20)
                .offset(x: -width*0.11, y: 70)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: 행 내 콘텐츠
    private func contentsView(_ width: CGFloat, item: Log) -> some View {
        ZStack(alignment: .bottomTrailing) {
            HStack(alignment: .top, spacing: 8) {
                Image(uiImage: DocumentManager.shared.loadImage(id: "\(item.id)"))
                    .resizable()
                    .frame(maxWidth: width*0.35, maxHeight: .infinity)
                    .background(.gray)
                    .clipShape(
                        .rect(topLeadingRadius: Resources.Radius.ticket, bottomLeadingRadius: Resources.Radius.ticket, bottomTrailingRadius: 0, topTrailingRadius: 0)
                    )
                LazyVStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .lineLimit(1)
                        .font(.headline)
                        .bold()
                    Text(item.content)
                        .lineLimit(3)
                        .font(Resources.Fonts.font14)
                }
                .padding(.top)
                .padding(.leading)
                .padding(.trailing, 12)
            }
            HStack {
                Text(item.place?.title ?? "")
                    .font(.caption)
                    .foregroundStyle(Resources.Colors.lightGray)
                if let tag = item.tag {
                    TagButton(tag: tag, action: {
                        
                    })
                }
            }
            .padding(.vertical, 8)
            .padding(.trailing, 8)
        }
    }
}
