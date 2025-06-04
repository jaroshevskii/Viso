//
//  MainAssembly.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 03.06.2025.
//

import UIKit
import Swinject

final class MainAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(MainViewModel.self) { _ in
            MainViewModel()
        }

        container.register(MainViewController.self) { resolver in
            let mainViewModel = resolver.resolve(MainViewModel.self)!
            return MainViewController(mainViewModel: mainViewModel)
        }

        container.register(MainCoordinator.self) { resolver, navigationController in
            MainCoordinator(navigationController: navigationController, resolver: resolver)
        }
    }
}
