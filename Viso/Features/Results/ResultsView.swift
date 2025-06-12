//
//  ResultsView.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 12.06.2025.
//

import SwiftUI

struct ResultsView: View {
    let image: ImageFile
    
    var body: some View {
        ZStack {
            List {
                if image.observations.isEmpty {
                    Text("No observations found.")
                } else {
                    ForEach(image.observations.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                        Text("\(value, specifier: "%.2f"): \(key.capitalized)")
                    }
                }
            }
            AsyncImage(url: image.url) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .opacity(0.2)
        }
    }
}
