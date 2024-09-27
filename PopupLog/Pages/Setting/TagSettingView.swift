//
//  TagSettingView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/22/24.
//

import SwiftUI
import RealmSwift

struct TagSettingView: View {
    @EnvironmentObject var viewStatus: CalendarViewStatus
    @ObservedResults (Tag.self) private var tagList
    @State private var color = Color.red
    
    var body: some View {
        ScrollView(showsIndicators: false, content: {
            VStack(alignment: .leading) {
                ZStack {
                    RoundedRectangle(cornerRadius: Resources.Radius.textContents)
                        .fill(Resources.Colors.white)
                    NavigationLink {
                        LazyNavigationView(AddOrEditTagView())
                    } label: {
                        HStack {
                            Text("태그 생성")
                                .foregroundStyle(Resources.Colors.black)
                                .padding()
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                
                Text("기본 태그 목록")
                    .font(.caption)
                    .foregroundStyle(Resources.Colors.lightGray)
                    .padding(.horizontal, 24)
                
                ZStack {
                    RoundedRectangle(cornerRadius: Resources.Radius.textContents)
                        .fill(Resources.Colors.white)
                    LazyVStack(alignment: .leading) {
                        ForEach(tagList.filter { $0.isDefault }, id: \.id) { tag in
                            HStack {
                                TagButton(tag: tag, action: {})
                                    .disabled(true)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(4)
                        }
                    }
                    .padding(8)
                }
                .padding(.horizontal)
                
                Text("사용자 태그 목록")
                    .font(.caption)
                    .foregroundStyle(Resources.Colors.lightGray)
                    .padding(.horizontal, 24)
                    .padding(.top)
                ZStack {
                    RoundedRectangle(cornerRadius: Resources.Radius.textContents)
                        .fill(Resources.Colors.white)
                        .overlay {
                            if tagList.filter({ !$0.isDefault }).isEmpty {
                                RoundedRectangle(cornerRadius: Resources.Radius.textContents)
                                    .fill(Resources.Colors.moreLightOrange)
                            }
                        }
                    LazyVStack {
                        ForEach(tagList.filter { !$0.isDefault }, id: \.id) { tag in
                            NavigationLink {
                                LazyNavigationView(AddOrEditTagView(tag: tag))
                            } label: {
                                HStack {
                                    TagButton(tag: tag, action: {})
                                        .disabled(true)
                                    Spacer()
                                    Resources.Images.next
                                        .foregroundStyle(Resources.Colors.lightGray)
                                }
                                .padding(4)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(8)
                }
                .padding(.horizontal)
                
                
            }
        })
        .background(Resources.Colors.moreLightOrange)
        .navigationTitle("태그 관리")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .onAppear {
            viewStatus.isPresentingSideMenu = false
            viewStatus.isMainView = false
        }
        .onDisappear {
            viewStatus.isPresentingBottomSheet = true
        }
        
    }
}
