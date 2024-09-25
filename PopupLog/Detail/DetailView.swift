//
//  DetailView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/21/24.
//

import SwiftUI
import RealmSwift

struct DetailView: View {
    @ObservedObject private var vm = DetailViewModel()
    @Environment(\.dismiss) private var dismiss
    @ObservedRealmObject var selectedLog: Log
    @ObservedResults (Log.self) private var logList
    
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
            .onAppear {
                // 수정할 데이터 보내기
                vm.action(.logData(log: selectedLog))
            }
        }
    }
}

// MARK: ViewUI
extension DetailView {
    // MARK: 날짜뷰
    private func dateView() -> some View {
        Text(selectedLog.visitDate.formatted(date: .numeric, time: .omitted))
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
                .fill(.white)
                .frame(height: proxy.size.height*0.8)
                .overlay {
                    if !vm.output.isFlipped {
                        frontView(proxy.size.width)
                    } else {
                        backView()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .scaleEffect(x: vm.output.isFlipped ? -1 : 1)
                .padding(.horizontal)
                .shadow(color: Resources.Colors.lightGray, radius: 12)
                .rotation3DEffect(.degrees(vm.output.isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .animation(.easeInOut(duration: 0.5), value: vm.output.isFlipped)
                .onTapGesture {
                    vm.action(.flip)
                }
        }
    }
    
    // MARK: 앞면 (이미지, 제목, 태그)
    func frontView(_ width: CGFloat) -> some View {
        VStack {
            Image("logo", bundle: nil)
                .resizable()
                .frame(width: width, height: width*0.9)
                .background(.blue)
            Spacer()
            VStack(spacing: 8) {
                Text(selectedLog.title)
                    .font(.headline)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    if let place = selectedLog.place, let title = place.title {
                        Text(title)
                            .font(.callout)
                            .foregroundStyle(Resources.Colors.lightGray)
                            .lineLimit(2)
                    }
                    if let tag = selectedLog.tag {
                       TagButton(tag: tag, action: {})
                            .disabled(true)
                    }
                }
            }
            .padding(.horizontal, 32)
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
                Text(vm.output.log.content)
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
                //  LazyNavigationView(AddOrEditView(logToEdit: vm.output.log))
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
