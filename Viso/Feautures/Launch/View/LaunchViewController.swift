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

    private lazy var titleLabel = makeTitleLabel()
    
    private lazy var statusLabel = makeStatusLabel()

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startObserving()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        launchViewModel.launch()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopObserving()
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
        view.addSubview(titleLabel)
        view.addSubview(statusLabel)
    }

    func configureLayout() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
        ])
    }
}

// MARK: - Builders
private extension LaunchViewController {
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
