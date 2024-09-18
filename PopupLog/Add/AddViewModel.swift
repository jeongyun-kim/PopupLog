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
    }
    
    enum Inputs {
        case save
        case textEditor
        case image(selected: Image)
        case placeSearch
        case presentTags
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
        }
    }
    
    struct Output {
        var place = ""
        var contentField = ""
        var presentPlaceSearchView = false
        var presentTagListView = false
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
    }
}
