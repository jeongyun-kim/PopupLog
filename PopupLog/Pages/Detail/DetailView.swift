//
//  DetailView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/21/24.
//

import SwiftUI
import RealmSwift

struct DetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedRealmObject var selectedLog: Log
    @ObservedResults(Log.self) private var logList
    @State private var isFlipped = true
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing) {
                dateView()
                flipView()
                Spacer()
            }
            .background(Resources.Colors.lightOrange)
            .navigationBar {
                dismissButton()
            } trailing: {
                menuView()
            }
        }
    }
}

// MARK: ViewUI
extension DetailView {
    // MARK: 날짜뷰
    private func dateView() -> some View {
        Text(selectedLog.visitDate.formattedDate)
            .padding(.horizontal)
            .padding(.top, 24)
            .padding(.bottom, 8)
            .font(.title3)
            .bold()
            .foregroundStyle(Resources.Colors.lightGray)
    }
    
    // MARK: 콘텐츠뷰 (+ 뒤집는 애니메이션)
    private func flipView() -> some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: Resources.Radius.ticket)
                .fill(Resources.Colors.white)
                .frame(height: proxy.size.height*0.8)
                .overlay {
                    if isFlipped {
                        frontView(proxy.size.width)
                    } else {
                        backView()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .scaleEffect(x: isFlipped ? -1 : 1)
                .padding(.horizontal)
                .shadow(color: Resources.Colors.lightGray, radius: 12)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .animation(.easeInOut(duration: 0.5), value: isFlipped)
                .onTapGesture {
                    isFlipped.toggle()
                }
        }
    }
    
    // MARK: 앞면 (이미지, 제목, 태그)
    func frontView(_ width: CGFloat) -> some View {
        VStack(spacing: 8) {
            Image(uiImage: DocumentManager.shared.loadImage(id: "\(selectedLog.id)") ?? Resources.Images.logo)
                .resizable()
                .frame(width: width, height: width*0.9)
                .padding(.bottom, 12)
            if let tag = selectedLog.tag {
               TagView(tag: tag)
            }
            VStack(spacing: 8) {
                Text(selectedLog.title)
                    .font(.headline)
                    .lineLimit(2)
                if let place = selectedLog.place, let title = place.title {
                    Text(title)
                        .font(.callout)
                        .foregroundStyle(Resources.Colors.lightGray)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: 뒷면 (제목, 내용)
    func backView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("✏️ \(selectedLog.title)")
                    .font(.title3)
                    .bold()
                    .lineLimit(nil)
                Rectangle()
                    .fill(Resources.Colors.lightGray.opacity(0.5))
                    .frame(height: 1)
                Text(selectedLog.content)
            }
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    // MARK: NavigationMenu
    private func menuView() -> some View {
        Menu {
            // 편집뷰로 이동
            NavigationLink {
                LazyNavigationView(AddOrEditView(logToEdit: selectedLog))
            } label: {
                Text("편집")
            }
            // 현재 기록 삭제
            Button(action: {
                $logList.remove(selectedLog)
                dismiss()
            }, label: {
                Text("삭제")
            })
        } label: {
            Resources.Images.more
                .frame(width: 40, height: 40)
        }
    }
    
    // MARK: Dismiss Button
    private func dismissButton() -> some View {
        Button(action: {
            dismiss()
        }, label: {
            Resources.Images.xmark
                .frame(width: 40, height: 40)
        })
    }
}
