//
//  AppCoordinator.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 03.06.2025.
//

import UIKit
import Swinject

final class AppCoordinator {
    
    private let window: UIWindow
    
    private let assembler: Assembler
    
    private let navigationController = UINavigationController()
    
    private var launchCoordinator: LaunchCoordinator?
    
    private var mainCoordinator: MainCoordinator?

    init(window: UIWindow, assembler: Assembler) {
        self.window = window
        self.assembler = assembler
    }

    func start() {
        window.rootViewController = navigationController

        let launchCoordinator = LaunchCoordinator(
            navigationController: navigationController,
            resolver: assembler.resolver
        )
        self.launchCoordinator = launchCoordinator

        launchCoordinator.onFinish = { [weak self] in
            self?.startMain()
            self?.launchCoordinator = nil
        }

        launchCoordinator.start()
    }
    
    private func startMain() {
        let mainCoordinator = MainCoordinator(
            navigationController: navigationController,
            resolver: assembler.resolver
        )
        self.mainCoordinator = mainCoordinator

        mainCoordinator.start()
    }
}
