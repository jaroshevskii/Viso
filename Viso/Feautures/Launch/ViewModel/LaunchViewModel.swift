//
//  LaunchViewModel.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 03.06.2025.
//

import Foundation

final class LaunchViewModel: ObservableObject {
    enum Status {
        case idle, loading, finished
    }
    
    @Published var status: Status = .idle

    func launch() {
        status = .loading
        
        Task {
            try? await Task.sleep(for: .seconds((0..<3).randomElement()!))
            status = .finished
        }
    }
}
