//
//  VisoApp.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 12.06.2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct VisoApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(
                store: Store(initialState: MainFeature.State()) {
                    MainFeature()
                }
            )
        }
    }
}
