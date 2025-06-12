//
//  ImageFile.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 12.06.2025.
//

import Foundation

struct ImageFile: Equatable, Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    var observations: [String: Float] = [:]
    
    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }
}
