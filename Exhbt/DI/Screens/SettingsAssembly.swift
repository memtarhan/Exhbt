//
//  SettingsAssembly.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 08/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import Swinject

class SettingsAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(SettingsViewController.self) { resolver in
            let view = SettingsViewController.instantiate()
            let viewModel = resolver.resolve(SettingsViewModel.self)
            view.viewModel = viewModel
            return view
        }
        container.register(SettingsViewModel.self) { _ in
            SettingsViewModel()
        }
    }
}
