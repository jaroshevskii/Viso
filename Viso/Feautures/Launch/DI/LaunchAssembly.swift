//
//  LaunchAssembly.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 03.06.2025.
//

import UIKit
import Swinject

final class LaunchAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(LaunchViewModel.self) { _ in
            LaunchViewModel()
        }

        container.register(LaunchViewController.self) { resolver in
            let launchViewModel = resolver.resolve(LaunchViewModel.self)!
            return LaunchViewController(launchViewModel: launchViewModel)
        }

        container.register(LaunchCoordinator.self) { resolver, navigationController in
            LaunchCoordinator(navigationController: navigationController, resolver: resolver)
        }
    }
}
