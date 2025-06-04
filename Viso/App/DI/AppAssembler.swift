//
//  AppAssembler.swift
//  Viso
//
//  Created by Sasha Jaroshevskii on 03.06.2025.
//

import Swinject

enum AppAssembler {
    static func `default`() -> Assembler {
        let assemblies: [Assembly] = [
            LaunchAssembly(),
            MainAssembly(),
        ]
        return Assembler(assemblies)
    }
}
