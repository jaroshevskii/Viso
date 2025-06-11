//
//  VisoApp.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 11.06.2025.
//

import SwiftUI
import Vision
import PhotosUI

struct MainView: View {
    @State private var imageURLS: [URL] = []
    @State private var images: [ImageFile] = []
    @State private var searchTerm = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showingPicker = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if imageURLS.isEmpty {
                    imageSelectionPrompt
                } else {
                    imageListSection
                }
            }
            .onChange(of: selectedItems) { oldItems, newItems in
                Task {
                    var newUrls: [URL] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            let tempDir = FileManager.default.temporaryDirectory
                            let filename = UUID().uuidString + ".jpg"
                            let fileURL = tempDir.appendingPathComponent(filename)
                            do {
                                try data.write(to: fileURL)
                                // Only add if not already present
                                if !imageURLS.contains(fileURL) && !newUrls.contains(fileURL) {
                                    newUrls.append(fileURL)
                                }
                            } catch {
                                print("Failed to write image data to disk: \(error)")
                            }
                        }
                    }
                    if !newUrls.isEmpty {
                        let combinedURLs = imageURLS + newUrls
                        imageURLS = combinedURLs
                        do {
                            let newImages = try await classifyAllImages(urls: newUrls)
                            images.append(contentsOf: newImages)
                        } catch {
                            print("Error during classification")
                        }
                    }
                }
            }

        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingPicker = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle("ClassifyingImages")
    }
    
    private var imageSelectionPrompt: some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: 0,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Label("Select Images", systemImage: "photo.on.rectangle.angled")
                .font(.title2)
                .padding()
        }
    }

    private var imageListSection: some View {
        VStack {
            Text("Click an image to view it's classification results")
                .font(.title2)
                .padding(.top)
                .task {
                    do {
                        images = try await classifyAllImages(urls: imageURLS)
                    } catch {
                        print("Error")
                    }
                }

            if images.count != imageURLS.count {
                ProgressView()
                    .progressViewStyle(.linear)
                    .frame(width: 300)
            } else {
                List {
                    ForEach(searchResults, id: \.url) { item in
                        NavigationLink(destination: ResultsView(image: item)) {
                            AsyncImage(url: item.url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 128, height: 128)
                            .clipShape(.rect(cornerRadius: 5))
                            .padding(10)

                            Text("\(item.name)")
                                .padding(20)
                                .font(.headline)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .searchable(text: $searchTerm)
            }
        }
    }
    
    var searchResults: [ImageFile] {
        if searchTerm.isEmpty {
            // If the search bar is empty, keep all of the images available.
            return images
        } else {
            // The only images that are available are those that contain classification labels equal to the search term.
            return images.filter({ $0.observations.keys.contains(searchTerm) })
        }
    }
}

