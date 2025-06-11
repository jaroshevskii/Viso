//
//  VisoApp.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 11.06.2025.
//

import SwiftUI
import Vision

struct ResultsView: View {
    var image: ImageFile
    
    var body: some View {
        ZStack {
            List {
                if image.observations.isEmpty {
                    Text("No observations found with significant confidence.")
                        .font(.title2)
                        .padding(10)
                }
                
                ForEach(image.observations.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                    Text("\(value, specifier: "%.2f"): \(key.capitalized)")
                        .font(.title2)
                        .padding(10)
                }
            }
            
            AsyncImage(url: image.url) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .aspectRatio(contentMode: .fill)
            .opacity(0.2)
        }
    }
}
