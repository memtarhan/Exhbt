//
//  NotificationSettingsAssembly.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 09/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import Swinject

class NotificationSettingsAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(NotificationSettingsViewController.self) { resolver in
            let view = NotificationSettingsViewController.instantiate()
            let viewModel = resolver.resolve(NotificationSettingsViewModel.self)
            view.viewModel = viewModel
            return view
        }
        container.register(NotificationSettingsViewModel.self) { _ in
            NotificationSettingsViewModel()
        }
    }
}
