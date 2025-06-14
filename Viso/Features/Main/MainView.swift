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
    
    @State private var exportURL: URL? = nil
    @State private var isShowingShareSheet = false

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
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
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(searchResults(viewStore), id: \.url) { image in
                                        NavigationLink(destination: ResultsView(image: image)) {
                                            VStack {
                                                AsyncImage(url: image.url) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        ProgressView()
                                                            .frame(height: 120)
                                                    case .success(let image):
                                                        image
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(height: 120)
                                                            .clipped()
                                                            .cornerRadius(12)
                                                    case .failure:
                                                        Image(systemName: "photo")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 120)
                                                            .foregroundColor(.gray)
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                                                Text(image.name)
                                                    .font(.caption)
                                                    .lineLimit(1)
                                                    .padding(.top, 4)
                                            }
                                            .padding()
                                            .background(Color(.systemBackground))
                                            .cornerRadius(12)
                                            .shadow(radius: 2)
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
                .navigationTitle("Viso")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Export All") {
                            exportCSV(images: viewStore.images)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        PhotosPicker(
                            selection: viewStore.binding(
                                get: \.selectedItems,
                                send: MainFeature.Action.didPickItems
                            ),
                            matching: .images
                        ) {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Pick More Images")
                    }
                }
                .sheet(isPresented: $isShowingShareSheet, onDismiss: {
                    if let url = exportURL {
                        try? FileManager.default.removeItem(at: url)
                        exportURL = nil
                    }
                }) {
                    if let exportURL = exportURL {
                        ShareSheet(activityItems: [exportURL])
                    }
                }
            }
        }
    }

    func exportCSV(images: [ImageFile]) {
        // CSV header
        var csvString = "ID,Observation,Confidence\n"
        
        for image in images {
            for (key, confidence) in image.observations.sorted(by: { $0.value > $1.value }) {
                // Escape commas or quotes if needed here (simple approach)
                let id = image.id
                csvString += "\(id),\(key),\(confidence)\n"
            }
        }
        
        // Save CSV to a temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("ImageObservations.csv")
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            exportURL = fileURL
            isShowingShareSheet = true
        } catch {
            print("Error writing CSV: \(error)")
        }
    }
    
    func searchResults(_ viewStore: ViewStore<MainFeature.State, MainFeature.Action>) -> [ImageFile] {
        let term = viewStore.searchTerm
        return term.isEmpty
        ? viewStore.images
        : viewStore.images.filter { $0.observations.keys.contains(term) }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
