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
                .navigationTitle("Viso")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Export All") {
                            exportCSV(images: viewStore.images)
                        }
                    }
                }
                // Share sheet presentation for exporting CSV file
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
