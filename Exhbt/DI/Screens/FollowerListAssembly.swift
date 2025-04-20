//
//  FollowerListAssembly.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 03/05/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class FollowerListAssembly: Assembly {
    func assemble(container: Container) {
        container.register(FollowerListViewController.self) { resolver in
            let view = FollowerListViewController.instantiate()
            let viewModel = resolver.resolve(FollowListViewModel.self)!
            let model = resolver.resolve(FollowListModel.self)!
            view.viewModel = viewModel
            viewModel.model = model
            return view
        }

        container.register(FollowListViewModel.self) { _ in
            FollowListViewModel()
        }

        container.register(FollowListModel.self) { resolver in
            FollowListModel(profileService: resolver.resolve(ProfileServiceProtocol.self)!, userService: resolver.resolve(UserServiceProtocol.self)!, meService: resolver.resolve(MeServiceProtocol.self)!)
        }
    }
}
