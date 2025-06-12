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
<<<<<<< HEAD:Viso/VisoApp.swift
               MainView()
=======
            MainView(
                store: Store(initialState: MainFeature.State()) {
                    MainFeature()
                }
            )
>>>>>>> tca-refactor:Viso/App/VisoApp.swift
        }
    }
}
