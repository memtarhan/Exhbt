//
//  UserAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 13/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class UserAssembly: Assembly {
    func assemble(container: Container) {
        container.register(UserViewController.self) { resolver in
            let view = UserViewController.instantiate()
            let viewModel = resolver.resolve(UserViewModel.self)!
            let model = resolver.resolve(UserModel.self)!

            viewModel.model = model
            view.viewModel = viewModel

            return view
        }

        container.register(UserViewModel.self) { _ in
            UserViewModel()
        }

        container.register(UserModel.self) { resolver in
            UserModel(userService: resolver.resolve(UserServiceProtocol.self)!, meService: resolver.resolve(MeServiceProtocol.self)!)
        }
    }
}
