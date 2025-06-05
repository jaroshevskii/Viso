//
//  LaunchViewController.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 03.06.2025.
//

import UIKit

final class LaunchViewController: UIViewController {
    var onFinish: (() -> Void)?
    
    private let launchViewModel: LaunchViewModel
    
    private var observationTasks = Set<Task<Void, Never>>()
    
    private var slideshowAnimator: ImageSlideshowAnimator?

    private lazy var titleLabel = makeTitleLabel()
    
    private lazy var statusLabel = makeStatusLabel()
    
    private lazy var animationImageView = makeAnimationImageView()
    
    init(launchViewModel: LaunchViewModel) {
        self.launchViewModel = launchViewModel
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureSlideshowAnimator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startObserving()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animationImageView.startAnimating()
        slideshowAnimator?.startAnimation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopObserving()
        slideshowAnimator?.stopAnimation()
    }
}

// MARK: - Observing
private extension LaunchViewController {
    func startObserving() {
        stopObserving()
        
        observationTasks.insert(Task {
            for await status in launchViewModel.$status.values {
                updateStatusLabel(using: status)
                
                if case .finished = status {
                    onFinish?()
                }
            }
        })
    }

    func stopObserving() {
        observationTasks.forEach { $0.cancel() }
        observationTasks.removeAll()
    }
}

// MARK: - UI Configuration
private extension LaunchViewController {
    func configureUI() {
        configureAppearance()
        configureHierarchy()
        configureLayout()
    }

    func configureAppearance() {
        view.backgroundColor = .systemBackground
    }

    func configureHierarchy() {
        view.addSubview(animationImageView)
        view.addSubview(titleLabel)
        view.addSubview(statusLabel)
    }

    func configureLayout() {
        NSLayoutConstraint.activate([
            animationImageView.topAnchor.constraint(equalTo: view.topAnchor),
            animationImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
        ])
    }
    
    func configureSlideshowAnimator() {
        var configuration = ImageSlideshowAnimator.Configuration()
        configuration.images = [
            UIImage(named: "cat")!,
            UIImage(named: "cat2")!,
            UIImage(named: "cat3")!,
            UIImage(named: "cat4")!,
            UIImage(named: "cat5")!
        ]
        configuration.interval = 0.5
        slideshowAnimator = ImageSlideshowAnimator(imageView: animationImageView, configuration: configuration)
    }
}

// MARK: - Builders
private extension LaunchViewController {
    func makeAnimationImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = "Launch"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func makeStatusLabel() -> UILabel {
        let label = UILabel()
        label.text = "Test"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}

// MARK: - Helpers
private extension LaunchViewController {
    func updateStatusLabel(using status: LaunchViewModel.Status) {
        statusLabel.text = switch status {
        case .idle: "Idle"
        case .loading: "Loading..."
        case .finished: "Finished!"
        }
    }
}
