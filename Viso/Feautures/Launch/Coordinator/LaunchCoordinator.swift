//
//  LaunchCoordinator.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 03.06.2025.
//

import UIKit
import Swinject

final class LaunchCoordinator {
    
    var onFinish: (() -> Void)?
    
    private let resolver: Resolver
    
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController, resolver: Resolver) {
        self.navigationController = navigationController
        self.resolver = resolver
    }

    func start() {
        let launchViewController = resolver.resolve(LaunchViewController.self)!
        
        launchViewController.onFinish = { [weak self] in
            self?.onFinish?()
        }
        
        navigationController.viewControllers = [launchViewController]
    }
}
