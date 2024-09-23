//
//  AddOrEditView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI
import PhotosUI
import RealmSwift

struct AddOrEditView: View {
    @Environment(\.dismiss) private var dismiss // PopVC 위한 변수
    @EnvironmentObject private var isPresentingSheet: CalendarViewSheetPresent
    @ObservedObject private var vm = AddViewModel()
    
    init(logToEdit: Log? = nil) {
        if let logToEdit {
            vm.action(.logToEdit(log: logToEdit))
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    photoPickerView(proxy.size.width)
                    popupInfoView()
                    titleView()
                    tagView()
                    contentsView()
                    Spacer()
                }
            }
        }
        .onAppear {
            // 기록을 추가할 때에는 BottomSheet를 내려야하지만 기록을 업데이트 할 때에는 BottomSheet가 내려가면 네비게이션 연결이 끊기므로 CalendarView로 돌아옴
            // 이를 방지하기 위해, 현재 뷰의 상태를 구분지어 줘야 함
            if !vm.output.isEditMode {
                isPresentingSheet.isPresenting.toggle()
            }
        }
        .onDisappear {
            if !vm.output.isEditMode {
                isPresentingSheet.isPresenting.toggle()
            }
        }
        .navigationBar { } trailing: {
            saveButton()
        }
        .navigationTitle("기록하기")
        .toolbarRole(.editor)
    }
}

// MARK: ViewUI
extension AddOrEditView {
    private func saveButton() -> some View {
        Button(action: {
            vm.action(.save)
            dismiss()
        }, label: {
            Text("저장")
        })
        // 제목 / 본문 비어있으면 저장 X
        .disabled(vm.output.contentField.isEmpty || vm.output.titleField.isEmpty)
    }
    
    // MARK: 제목
    private func titleView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("제목*")
                .padding(.horizontal)
                .font(.headline)
            TextField("제목을 입력해주세요", text: $vm.output.titleField)
                .asRoundedTextField()
        }
        .padding(.bottom, 8)
    }
    
    // MARK: 본문
    private func contentsView() -> some View {
        VStack(alignment: .leading) {
            Text("본문*")
                .font(.headline)
            ZStack(alignment: .leading) {
                // TextEditor Placeholder
                if vm.output.contentField.isEmpty {
                    VStack {
                        Text("다녀오신 팝업은 어땠나요?\n다양한 이야기를 적어주세요 :)")
                            .foregroundStyle(Resources.Colors.lightGray)
                            .padding()
                        Spacer()
                    }
                }
                TextEditor(text: $vm.output.contentField)
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .opacity(vm.output.contentField.isEmpty ? 0.3 : 1)
                    .padding(8)
                    .overlay {
                        RoundedRectangle(cornerRadius: Resources.Radius.textContents)
                            .strokeBorder(lineWidth: 1)
                            .foregroundStyle(Resources.Colors.lightGray)
                    }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: 태그
    private func tagView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("태그")
                    .font(.headline)
                // 선택된 태그있으면 보여주기
                if let tag = vm.output.selectedTag {
                    TagButton(tag: tag) {
                        vm.action(.selectedTag(tag: nil)) // 선택된 태그 해제
                    }
                }
                Spacer()
                Button(action: {
                    // sheet 이용해 모든 태그리스트 띄우기
                    vm.action(.presentTags)
                }, label: {
                    Text("모두 보기")
                        .font(.callout)
                        .foregroundStyle(Resources.Colors.lightGray)
                })
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(TagRepository.shared.getAllTags(), id: \.id) { tag in
                        TagButton(tag: tag) {
                            vm.action(.selectedTag(tag: tag))
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $vm.output.presentTagListView, content: {
            NavigationStack {
                VStack {
                    sheetPushTagSettingView()
                    sheetTagListView()
                }
                .background(Resources.Colors.moreLightOrange)
                .navigationTitle("태그 목록")
                .navigationBarTitleDisplayMode(.inline)
            }
        })
    }
    
    // MARK: 태그 리스트 -> 태그 관리
    private func sheetPushTagSettingView() -> some View {
        HStack {
            Spacer()
            NavigationLink {
                LazyNavigationView(TagSettingView())
            } label: {
                HStack(spacing: 4) {
                    Resources.Images.setting
                    Text("태그 관리")
                        .font(.callout)
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: 모든 태그 리스트
    private func sheetTagListView() -> some View {
        ScrollView(showsIndicators: false) {
            ZStack {
                RoundedRectangle(cornerRadius: Resources.Radius.textContents)
                    .fill(Resources.Colors.white)
                LazyVStack(alignment: .leading) {
                    ForEach(TagRepository.shared.getAllTags(), id: \.id) { tag in
                        HStack {
                            TagButton(tag: tag) {
                                vm.action(.selectedTag(tag: tag))
                                vm.action(.presentTags)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(4)
                    }
                }
                .padding()
            }
            .padding()
        }
    }
    
    // MARK: 방문일 & 팝업검색
    private func popupInfoView() -> some View {
        VStack(alignment: .leading) {
            // 방문일뷰
            HStack(spacing: 30) {
                HStack(spacing: 0) {
                    Text("방문일*")
                        .font(.callout)
                        .bold()
                    DatePicker("", selection: $vm.input.visitedDate, in: ...Date(), displayedComponents: .date)
                        .tint(Resources.Colors.primaryColor)
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                }
                Spacer()
                searchPlaceButton()
            }
            .offset(y: -16)
            // 장소뷰
            HStack {
                Text("장소")
                    .font(.headline)
                ZStack(alignment: .leading) {
                    Text("장소를 검색해주세요") // 검색 장소
                        .foregroundStyle(Resources.Colors.lightGray)
                        .opacity(vm.output.place.isEmpty ? 1 : 0) // 선택한 장소가 없다면 '장소를 검색해주세요' 숨기기
                    Text(vm.output.place) // 검색 장소 결과 주소
                        .font(.callout)
                }
                Spacer()
                // 선택한 장소가 있다면 장소가 있다면 장소 지울 수 있게
                if !vm.output.place.isEmpty {
                    Button(action: {
                        vm.action(.removePlace)
                    }, label: {
                        Resources.Images.xmark
                            .foregroundStyle(Resources.Colors.lightGray)
                    })
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 6)
    }
    
    // MARK: 검색 버튼
    private func searchPlaceButton() -> some View {
        Button(action: {
            vm.action(.placeSearch)
        }, label: {
            HStack(spacing: 4) {
                Resources.Images.search
                Text("장소 검색")
                    .font(.callout)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 6)
            .foregroundStyle(Resources.Colors.black)
            .background(Resources.Colors.systemGray6)
            .clipShape(.rect(cornerRadius: Resources.Radius.button))
        })
        .sheet(isPresented: $vm.output.presentPlaceSearchView, content: {
            VStack {
                TextField("장소를 검색해보세요", text: $vm.output.placeField)
                    .asRoundedTextField()
                    .padding(.top, 32)
                    .onSubmit(of: .text) {
                        vm.action(.searchPlace)
                    }
                searchPlaceListView()
            }
            .presentationDetents([.medium])
        })
    }
    
    // MARK: 검색결과 리스트
    private func searchPlaceListView() -> some View {
        List {
            ForEach(vm.output.searchedPlaces, id: \.id) { item in
                Button(action: {
                    vm.action(.selectedPlace(place: item))
                }, label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.replacedTitle)
                            .bold()
                        Text(item.roadAddress)
                            .foregroundStyle(Resources.Colors.lightGray)
                            .lineLimit(2)
                    }
                    .font(.callout)
                    .padding(.vertical, 8)
                })
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: 사진
    private func photoPickerView(_ width: CGFloat) -> some View {
        ZStack(alignment: .center) {
            PhotosPicker(selection: $vm.output.selectedPhotoItem, matching: .images) {
                RoundedRectangle(cornerRadius: Resources.Radius.image)
                    .fill(Resources.Colors.lightOrange)
                    .foregroundStyle(Resources.Colors.primaryColor)
                    .padding()
                    .frame(width: width, height: width)
                    .overlay {
                        photoPickerImageView()
                    }
            }
            .changedImage($vm.output.selectedPhotoItem) { value in
                vm.action(.image(selected: value))
            }
        }
        .padding(.top)
    }
    
    // MARK: PhotoPickerLabel
    private func photoPickerImageView() -> some View {
        RoundedRectangle(cornerRadius: Resources.Radius.textContents)
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [8]))
            .opacity(vm.output.isSelectedImage ? 0 : 1)
            .overlay {
                if !vm.output.isSelectedImage {
                    emptyImageView()
                } else {
                    // 사용자가 이미지를 선택한 경우
                    nonEmptyImageView()
                }
            }
            .foregroundStyle(Resources.Colors.primaryColor)
            .padding()
    }
    
    // MARK: 선택한 이미지 O
    private func nonEmptyImageView() -> some View {
        ZStack(alignment: .topTrailing) {
            vm.output.selectedImage // 사용자 선택 이미지
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: Resources.Radius.image))
            // 변경한 사진 제거
            Button(action: {
                vm.action(.image(selected: Resources.Images.plus))
            }, label: {
                Resources.Images.xmark
                    .resizable()
                    .padding()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(Resources.Colors.lightGray)
            })
        }
    }
    
    // MARK: 선택 이미지 X
    private func emptyImageView() -> some View {
        VStack(spacing: 4) {
            Resources.Images.plus
            Text("사진 추가")
        }
        .padding(.top)
    }
}
