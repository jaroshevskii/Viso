//
//  MainFeature.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 12.06.2025.
//

import ComposableArchitecture
import SwiftUI
import PhotosUI

struct MainFeature: Reducer {
    @Dependency(\.imageClassifier) var classifier

    struct State: Equatable {
        @BindingState var selectedItems: [PhotosPickerItem] = []
        @BindingState var searchTerm: String = ""
        var imageURLs: [URL] = []
        var images: [ImageFile] = []
        var isLoading = false
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case didPickItems([PhotosPickerItem])
        case classifyImages([URL])
        case classificationResponse(Result<[ImageFile], Error>)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .binding:
            return .none

        case .didPickItems(let items):
            state.selectedItems = items
            state.isLoading = true
            return .run { [items] send in
                var urls: [URL] = []
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
                        try data.write(to: url)
                        urls.append(url)
                    }
                }
                await send(.classifyImages(urls))
            }

        case .classifyImages(let urls):
            state.imageURLs.append(contentsOf: urls)
            return .run { [urls] send in
                do {
                    let images = try await classifier.classifyAllImages(urls)
                    await send(.classificationResponse(.success(images)))
                } catch {
                    await send(.classificationResponse(.failure(error)))
                }
            }

        case .classificationResponse(let result):
            state.isLoading = false
            switch result {
            case .success(let images):
                state.images.append(contentsOf: images)
            case .failure:
                break
            }
            return .none
        }
    }
}
