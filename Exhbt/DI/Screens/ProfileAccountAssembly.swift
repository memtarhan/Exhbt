//
//  ProfileAccountAssembly.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 08/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject

class ProfileAccountAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ProfileAccountViewController.self) { resolver in
            let view = ProfileAccountViewController.instantiate()
            let viewModel = resolver.resolve(ProfileAccountViewModel.self)
            let model = resolver.resolve(ProfileAccountModel.self)
            view.viewModel = viewModel
            viewModel?.view = view
            viewModel?.model = model
            return view
        }
        container.register(ProfileAccountViewModel.self) { _ in
            ProfileAccountViewModel()
        }
        container.register(ProfileAccountModel.self) { resolver in
            ProfileAccountModel(service: resolver.resolve(MeServiceProtocol.self)!,
                                realtimeSyncService: resolver.resolve(MeRealtimeSyncService.self)!)
        }
    }
}
