//
//  MainCoordinator.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 03.06.2025.
//

import UIKit
import Swinject

final class MainCoordinator {
    private let resolver: Resolver
    
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController, resolver: Resolver) {
        self.navigationController = navigationController
        self.resolver = resolver
    }

    func start() {
        let mainViewController = resolver.resolve(MainViewController.self)!
        navigationController.setViewControllers([mainViewController], animated: true)
    }
}
