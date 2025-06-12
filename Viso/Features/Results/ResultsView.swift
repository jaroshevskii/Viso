//
//  ResultsView.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 12.06.2025.
//

import SwiftUI

struct ResultsView: View {
    let image: ImageFile

    private let columns = [
        GridItem(spacing: 8)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if image.observations.isEmpty {
                    Text("No observations found.")
                        .padding(8)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                        ForEach(image.observations.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                            Text("\(key.replacingOccurrences(of: "_", with: " ").capitalizedFirstLetterOnly()): \(value)")
                                .padding(8)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding()
        }
        .background(
            BlurredImageBackground(url: image.url)
                .ignoresSafeArea()
        )
        .navigationTitle("Results")
    }
}

struct BlurredImageBackground: View {
    let url: URL

    @State private var blurAmount: CGFloat = 20
    
    @State private var overlayOpacity: Double = 1

    var body: some View {
        ZStack {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .blur(radius: blurAmount)
                        .animation(.easeOut(duration: 1), value: blurAmount)
                        .onAppear {
                            blurAmount = 5
                            overlayOpacity = 0.6
                        }
                default:
                    Color.black
                }
            }

            Color.black
                .opacity(overlayOpacity)
                .animation(.easeOut(duration: 1), value: overlayOpacity)
        }
        .ignoresSafeArea()
    }
}

extension String {
    func capitalizedFirstLetterOnly() -> String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst()
    }
}
