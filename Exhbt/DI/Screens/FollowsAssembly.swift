//
//  FollowsAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 06/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class FollowsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(FollowsViewController.self) { resolver in
            let view = FollowsViewController.instantiate()
            let viewModel = resolver.resolve(FollowsViewModel.self)!
            let model = resolver.resolve(FollowsModel.self)!

            viewModel.model = model
            view.viewModel = viewModel

            return view
        }

        container.register(FollowsViewModel.self) { _ in
            FollowsViewModel()
        }

        container.register(FollowsModel.self) { resolver in
            FollowsModel(meService: resolver.resolve(MeServiceProtocol.self)!,
                         userService: resolver.resolve(UserServiceProtocol.self)!)
        }
    }
}
