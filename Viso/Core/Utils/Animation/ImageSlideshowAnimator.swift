//
//  ImageSlideshowAnimator.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 06.06.2025.
//

import UIKit

final class ImageSlideshowAnimator {
    
    struct Configuration {
        var images: [UIImage] = []
        
        var interval: TimeInterval = 1.0
        
        var transitionDuration: TimeInterval = 0.5
        
        var transitionOptions: UIView.AnimationOptions = .transitionCurlUp
        
        var isRepeating = true
        
        init() {}
    }
    
    private var task: Task<Void, Never>?
    
    private let configuration: Configuration
    
    private let imageView: UIImageView
    
    init(imageView: UIImageView, configuration: Configuration) {
        self.imageView = imageView
        self.configuration = configuration
    }
    
    func startAnimation(completion: (() -> Void)? = nil) {
        stopAnimation()

        guard !configuration.images.isEmpty else {
            completion?()
            return
        }

        task = Task { [weak self] in
            defer { completion?() }

            guard let self = self else { return }
            
            await MainActor.run {
                self.imageView.image = self.configuration.images[0]
            }

            let count = self.configuration.images.count
            var index = 1

            while !Task.isCancelled {
                if index >= count {
                    if configuration.isRepeating {
                        index = 0
                    } else {
                        break
                    }
                }

                let image = self.configuration.images[index]

                await UIView.transition(
                    with: self.imageView,
                    duration: self.configuration.transitionDuration,
                    options: self.configuration.transitionOptions
                ) {
                    self.imageView.image = image
                }

                index += 1

                try? await Task.sleep(for: .seconds(self.configuration.interval))
            }
        }
    }

    
    func stopAnimation() {
        task?.cancel()
        task = nil
    }
}
