//
//  NotificationsAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/09/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class NotificationsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(NotificationsViewController.self) { resolver in
            let view = NotificationsViewController.instantiate()
            let viewModel = resolver.resolve(NotificationsViewModel.self)!
            let model = resolver.resolve(NotificationsModel.self)!

            view.viewModel = viewModel
            viewModel.model = model

            return view
        }

        container.register(NotificationsViewModel.self) { _ in
            NotificationsViewModel()
        }

        container.register(NotificationsModel.self) { resolver in
            NotificationsModel(service: resolver.resolve(MeServiceProtocol.self)!,
                               eventService: resolver.resolve(EventServiceProtocol.self)!)
        }
    }
}
