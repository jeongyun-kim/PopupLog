//
//  AddViewModel.swift
//  PopupLog
//
//  Created by 김정윤 on 9/18/24.
//

import SwiftUI
import Combine
import PhotosUI

final class AddViewModel: BaseViewModel {
    var subscriptions = Set<AnyCancellable>()
    var input = Input()
    @Published var output = Output()
    
    struct Input {
        var logId: UUID? = nil
        var titleField = ""
        var visitedDate = Date()
        var selectedImage = CurrentValueSubject<Image, Never>(Resources.Images.plus)
        var saveBtnTapped = PassthroughSubject<Void, Never>()
        var textEditorTapped = PassthroughSubject<Void, Never>()
        var placeSearchBtnTapped = PassthroughSubject<Void, Never>()
        var presentTagsBtnTapped = PassthroughSubject<Void, Never>()
        var searchPlace = PassthroughSubject<Void, Never>()
        var selectedPlace = CurrentValueSubject<Place?, Never>(nil)
        var removePlace = PassthroughSubject<Void, Never>()
    }
    
    enum Inputs {
        case save
        case textEditor
        case image(selected: Image)
        case placeSearch
        case presentTags
        case searchPlace
        case selectedPlace(place: Place)
        case removePlace
    }
    
    func action(_ inputs: Inputs) {
        switch inputs {
        case .save:
            return input.saveBtnTapped.send(())
        case .textEditor:
            return input.textEditorTapped.send(())
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
        }
    }
    
    struct Output {
        var place = ""
        var contentField = ""
        var presentPlaceSearchView = false
        var presentTagListView = false
        var placeField = ""
        var searchedPlaces: [Place] = []
    }
    
    init() {
        input.saveBtnTapped
            .sink { _ in
                print(self.input.selectedImage.value)
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
                self.output.place = value.replacedTitle // 장소 정보 가져와 보여주기 
                self.output.presentPlaceSearchView.toggle() // sheet 내리기
                self.output.searchedPlaces = [] // 검색결과 비워주고
                self.output.placeField = "" // 검색 키워드 비워주기
            }.store(in: &subscriptions)
        
        input.removePlace
            .sink { [weak self] _ in
                guard let self else { return }
                self.output.place = ""
            }.store(in: &subscriptions)
    }
}
