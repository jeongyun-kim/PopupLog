//
//  AddOrEditView.swift
//  PopupLog
//
//  Created by 김정윤 on 9/16/24.
//

import SwiftUI
import PhotosUI
import RealmSwift
import SwiftyCrop

struct AddOrEditView: View {
    @Environment(\.dismiss) private var dismiss // PopVC 위한 변수
    @EnvironmentObject private var viewStatus: CalendarViewStatus
    @ObservedObject private var vm = AddViewModel()
    @ObservedResults(Log.self) private var logList
    
    init(logToEdit: Log? = nil, selectedDate: Date? = nil) {
        if let selectedDate {
            vm.action(.visitedDate(date: selectedDate))
        }
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
        .onTapGesture(count: 99) {}
        .onTapGesture {
            self.endTextEditing()
        }
        .onAppear {
            // 기록을 추가할 때에는 BottomSheet를 내려야하지만 기록을 업데이트 할 때에는 BottomSheet가 내려가면 네비게이션 연결이 끊기므로 CalendarView로 돌아옴
            // 이를 방지하기 위해, 현재 뷰의 상태를 구분지어 줘야 함
            if !vm.output.isEditMode {
                viewStatus.isPresentingBottomSheet.toggle()
            }
        }
        .onDisappear {
            if !vm.output.isEditMode {
                viewStatus.isPresentingBottomSheet.toggle()
            }
        }
        .navigationBar { } trailing: {
            saveButton()
        }
        .navigationTitle("기록하기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
    }
}

// MARK: ViewUI
extension AddOrEditView {
    private func saveButton() -> some View {
        Button(action: {
            vm.action(.save)
            if !vm.output.isEditMode {
                $logList.append(vm.output.logToSave)
            }
            dismiss()
        }, label: {
            Text("저장")
        })
        // 제목 / 본문 비어있으면 저장 X
        .disabled(vm.output.contentField.isEmptyRemovedSpace
                  || vm.output.titleField.isEmptyRemovedSpace)
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
            Text("후기*")
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
                    TagView(tag: tag)
                        .onTapGesture {
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
                        TagView(tag: tag)
                            .onTapGesture {
                                vm.action(.selectedTag(tag: tag))
                            }
                    }
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $vm.output.presentTagListView, content: {
            tagSheetView()
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
                    Text("태그 관리")
                        .font(.callout)
                }
            }
        }
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
                            TagView(tag: tag)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(4)
                        .background(Resources.Colors.white)
                        .onTapGesture {
                            vm.action(.selectedTag(tag: tag))
                            vm.action(.presentTags)
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
    }
    
    // MARK: TagSheetView
    private func tagSheetView() -> some View {
        NavigationStack {
            sheetTagListView()
                .padding(.horizontal)
                .background(Resources.Colors.moreLightOrange)
                .navigationTitle("태그 목록")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBar {
                    Button {
                        vm.action(.presentTags)
                    } label: {
                        Text("취소")
                    }
                } trailing: {
                    sheetPushTagSettingView()
                }
        }
    }
    
    // MARK: 방문일 & 팝업검색
    private func popupInfoView() -> some View {
        VStack(alignment: .leading) {
            // 방문일뷰
            HStack {
                HStack(spacing: 12) {
                    Text("방문일*")
                        .font(.callout)
                        .bold()
                    DatePicker("", selection: $vm.output.visitedDate, displayedComponents: .date)
                        .tint(Resources.Colors.primaryColor)
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                        .frame(width: 100)
                }
                Spacer()
            }
            .offset(y: -16)
            // 장소뷰
            HStack {
                Text("장소")
                    .font(.headline)
                searchPlaceButton()
                Spacer()
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
        Button {
            vm.action(.placeSearch)
        } label: {
            ZStack(alignment: .leading) {
                Text("장소를 검색해보세요 👀") // 검색 장소
                    .foregroundStyle(Resources.Colors.black)
                    .opacity(vm.output.place.isEmpty ? 1 : 0) // 선택한 장소가 없다면 '장소를 검색해주세요' 숨기기
                Text(vm.output.place) // 검색 장소 결과 주소
                    .font(.callout)
                    .foregroundStyle(Resources.Colors.black)
                    .lineLimit(1)
            }
        }
        .padding(8)
        .background(vm.output.place.isEmpty ? Color(.systemGray5).opacity(0.7) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: Resources.Radius.button))
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
        .overlay {
            Text(vm.output.emptyPlaceText)
                .foregroundStyle(Resources.Colors.lightGray)
        }
        
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
                vm.output.isPresentingCropView.toggle()
                vm.action(.image(selected: value))
            }
        }
        .padding(.top)
        .fullScreenCover(isPresented: $vm.output.isPresentingCropView) {
            imageCropView(width)
        }
    }
    
    // MARK: ImageCropView
    private func imageCropView(_ size: CGFloat) -> some View {
        let configuration = SwiftyCropConfiguration(
            maskRadius: size,
            rectAspectRatio: 1/1
        )
        
        return SwiftyCropView(
            imageToCrop: vm.output.selectedImage,
            maskShape: .square,
            configuration: configuration
        ) { croppedImage in
            if let croppedImage {
                vm.action(.image(selected: croppedImage))
            }
        }
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
            // 사용자 선택 이미지
            Image(uiImage: vm.output.selectedImage)
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: Resources.Radius.image))
            // 변경한 사진 제거
            Button(action: {
                vm.action(.image(selected: Resources.Images.plusUK))
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

