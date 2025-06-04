//
//  MainViewController.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 03.06.2025.
//

import UIKit

final class MainViewController: UIViewController {
    
    private let mainViewModel: MainViewModel
    
    private var observationTasks = Set<Task<Void, Never>>()

    private lazy var titleLabel = makeTitleLabel()

    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
        
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
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopObserving()
    }
}

// MARK: - Observing
private extension MainViewController {
    func startObserving() {
        stopObserving()
        
        observationTasks.insert(Task {
//            for await status in launchViewModel.$status.values {
//                updateStatusLabel(using: status)
//                
//                if case .finished = status {
//                    onFinish?()
//                }
//            }
        })
    }

    func stopObserving() {
        observationTasks.forEach { $0.cancel() }
        observationTasks.removeAll()
    }
}

// MARK: - UI Configuration
private extension MainViewController {
    func configureUI() {
        configureAppearance()
        configureHierarchy()
        configureLayout()
    }

    func configureAppearance() {
        view.backgroundColor = .magenta
    }

    func configureHierarchy() {
        view.addSubview(titleLabel)
    }

    func configureLayout() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

// MARK: - Builders
private extension MainViewController {
    func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = "Main"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}

// MARK: - Helpers
private extension MainViewController {}
