//
//  AddViewModel.swift
//  PopupLog
//
//  Created by 김정윤 on 9/18/24.
//

import SwiftUI
import PhotosUI
import Combine
import RealmSwift

final class AddViewModel: BaseViewModel {
    private let logRepo = LogRepository.shared
    var subscriptions = Set<AnyCancellable>()
    var input = Input()
    @Published var output = Output()
    
    struct Input {
        var visitedDate = Date() // 방문일
        var selectedImage = CurrentValueSubject<Image, Never>(Resources.Images.plus) // 선택한 이미지
        var saveBtnTapped = PassthroughSubject<Void, Never>() // 저장버튼 탭
        var placeSearchBtnTapped = PassthroughSubject<Void, Never>() // 장소검색 버튼 탭
        var presentTagsBtnTapped = PassthroughSubject<Void, Never>() // 태그 모두보기 탭
        var searchPlace = PassthroughSubject<Void, Never>() // 장소검색 돌리기
        var selectedPlace = CurrentValueSubject<Place?, Never>(nil) // 선택된 장소
        var removePlace = PassthroughSubject<Void, Never>() // 장소 지우기 탭
        var selectedTag = PassthroughSubject<Tag?, Never>() // 선택된 태그
        var logToEdit = CurrentValueSubject<Log?, Never>(nil)
    }
    
    enum Inputs {
        case save
        case image(selected: Image)
        case placeSearch
        case presentTags
        case searchPlace
        case selectedPlace(place: Place)
        case removePlace
        case selectedTag(tag: Tag?)
        case logToEdit(log: Log)
    }
    
    func action(_ inputs: Inputs) {
        switch inputs {
        case .save:
            return input.saveBtnTapped.send(())
        case .image(let selectedImage):
            return input.selectedImage.send(selectedImage)
        case .placeSearch:
            return input.placeSearchBtnTapped.send(())
        case .presentTags:
            return input.presentTagsBtnTapped.send(())
        case .searchPlace:
            return input.searchPlace.send(())
        case .selectedPlace(let place):
            return input.selectedPlace.send(place)
        case .removePlace:
            return input.removePlace.send(())
        case .selectedTag(let tag):
            return input.selectedTag.send(tag)
        case .logToEdit(let log):
            return input.logToEdit.send(log)
        }
    }
    
    struct Output {
        var contentField = "" // 본문
        var placeField = "" // 검색할 장소명
        var presentPlaceSearchView = false // 장소검색뷰 보여줄지 말지
        var searchedPlaces: [Place] = [] // 검색장소 리스트
        var place = "" // 사용자에게 보여줄 현재 장소명
        var selectedPlace: Place? = nil // 현재 선택된 장소
        var presentTagListView = false // 태그뷰 보여줄지 말지
        var selectedTag: Tag? = nil // 선택 태그
        var isSelectedImage = false // 사진이 선택된 상태인지
        var selectedImage: Image = Resources.Images.plus // 현재 사진
        var selectedPhotoItem: PhotosPickerItem? = nil // 선택된 사진
        var titleField = ""
        var isEditMode = false
    }
    
    init() {
        input.saveBtnTapped
            .sink { [weak self] _ in
                guard let self else { return }
                let title = self.output.titleField
                let content = self.output.contentField
                let data = self.output.selectedPlace
                let place = DBPlace(title: data?.replacedTitle, roadAddress: data?.roadAddress, mapX: data?.mapx, mapY: data?.mapy)
                let tag = self.output.selectedTag
                let date = self.input.visitedDate
                
                if output.isEditMode {
                    logRepo.updateLog(input.logToEdit.value, title: title, content: content, place: place, tag: tag, visitDate: date)
                } else {
                    let log = Log(title: title, content: content, place: place, tag: tag, visitDate: date)
                    logRepo.addLog(log)
                }
            }.store(in: &subscriptions)
        
        input.placeSearchBtnTapped
            .sink { [weak self] _ in
                guard let self else { return }
                self.output.presentPlaceSearchView = true
            }.store(in: &subscriptions)
        
        input.presentTagsBtnTapped
            .sink { [weak self] _ in
                guard let self else { return }
                self.output.presentTagListView = true
            }.store(in: &subscriptions)
        
        input.searchPlace
            .sink { [weak self] _ in
                guard let self else { return }
                let keyword = self.output.placeField
                guard !keyword.isEmpty else { return }
                NetworkService.shared.searchPlace(keyword) { result in
                    switch result {
                    case .success(let value):
                        self.output.searchedPlaces = value.items
                    case .failure(let error):
                        print(error)
                    }
                }
            }.store(in: &subscriptions)
        
        input.selectedPlace
            .sink { [weak self] value in
                guard let self, let value else { return }
                self.output.selectedPlace = value
                self.output.place = value.replacedTitle // 장소 정보 가져와 보여주기
                self.output.presentPlaceSearchView.toggle() // sheet 내리기
                self.output.searchedPlaces = [] // 검색결과 비워주고
                self.output.placeField = "" // 검색 키워드 비워주기
            }.store(in: &subscriptions)
        
        input.removePlace
            .sink { [weak self] _ in
                guard let self else { return }
                self.output.place = ""
                self.output.selectedPlace = nil
            }.store(in: &subscriptions)
        
        input.selectedTag
            .sink { [weak self] value in
                guard let self else { return }
                self.output.selectedTag = value
            }.store(in: &subscriptions)
        
        input.selectedImage
            .sink { [weak self] value in
                guard let self else { return }
                self.output.isSelectedImage = value != Resources.Images.plus
                self.output.selectedImage = value
                // 만약 현재 사진이 선택되어있는 상태가 아니라면 photoItem 지우기
                guard !self.output.isSelectedImage else { return }
                self.output.selectedPhotoItem = nil
            }.store(in: &subscriptions)
        
        input.logToEdit
            .sink { [weak self] value in
                guard let self else { return }
                guard let value else { return }
                self.output.isEditMode = true
                self.output.titleField = value.title
                self.output.contentField = value.content
                self.output.selectedTag = value.tag
                self.input.visitedDate = value.visitDate
                guard let place = value.place, let title = place.title else { return }
                self.output.place = title
            }.store(in: &subscriptions)
    }
}
