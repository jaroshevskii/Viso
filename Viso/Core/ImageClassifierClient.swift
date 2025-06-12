//
//  ImageClassifierClient.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 12.06.2025.
//

import ComposableArchitecture
import Vision

@DependencyClient
struct ImageClassifierClient {
    var classifyImage: (URL) async throws -> ImageFile
    var classifyAllImages: ([URL]) async throws -> [ImageFile]
}

extension ImageClassifierClient: DependencyKey {
    static let liveValue: Self = {
        let classifyImageImpl: (URL) async throws -> ImageFile = { url in
            var image = ImageFile(url: url)
            let request = ClassifyImageRequest()
            let results = try await request.perform(on: url)
                .filter { $0.hasMinimumPrecision(0.1, forRecall: 0.8) }
            for classification in results {
                image.observations[classification.identifier] = classification.confidence
            }
            return image
        }

        return Self(
            classifyImage: classifyImageImpl,
            classifyAllImages: { urls in
                try await withThrowingTaskGroup(of: ImageFile.self) { group in
                    for url in urls {
                        group.addTask {
                            try await classifyImageImpl(url)
                        }
                    }
                    return try await group.reduce(into: []) { $0.append($1) }
                }
            }
        )
    }()
}

extension DependencyValues {
    var imageClassifier: ImageClassifierClient {
        get { self[ImageClassifierClient.self] }
        set { self[ImageClassifierClient.self] = newValue }
    }
}
