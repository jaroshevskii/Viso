//
//  MainView.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 12.06.2025.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI

struct MainView: View {
    let store: StoreOf<MainFeature>

    var body: some View {
        WithViewStore(self.store, observe: \.self) { viewStore in
            NavigationStack {
                VStack {
                    if viewStore.imageURLs.isEmpty {
                        PhotosPicker(
                            selection: viewStore.binding(
                                get: \.selectedItems,
                                send: MainFeature.Action.didPickItems
                            ),
                            matching: .images
                        ) {
                            Label("Select Images", systemImage: "photo")
                        }
                    } else {
                        if viewStore.isLoading {
                            ProgressView()
                        } else {
                            List {
                                ForEach(searchResults(viewStore), id: \.url) { image in
                                    NavigationLink(destination: ResultsView(image: image)) {
                                        HStack {
                                            AsyncImage(url: image.url) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 44, height: 44)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                case .failure:
                                                    Image(systemName: "photo")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 44, height: 44)
                                                        .foregroundColor(.gray)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            Text(image.name)
                                                .lineLimit(1)
                                                .padding(.leading, 8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
//                .searchable(
//                    text: viewStore.binding(\.$searchTerm),
//                    prompt: "Search images"
//                )
                .navigationTitle("ClassifyingImages")
            }
        }
    }

    func searchResults(_ viewStore: ViewStore<MainFeature.State, MainFeature.Action>) -> [ImageFile] {
        let term = viewStore.searchTerm
        return term.isEmpty
            ? viewStore.images
            : viewStore.images.filter { $0.observations.keys.contains(term) }
    }
}

