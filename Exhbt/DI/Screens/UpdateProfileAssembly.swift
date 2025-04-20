//
//  UpdateProfileAssembly.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 22/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import Swinject

class UpdateProfileAssembly: Assembly {
    func assemble(container: Container) {
        container.register(UpdateProfileViewController.self) { resolver in
            let view = UpdateProfileViewController.instantiate()
            let viewModel = resolver.resolve(UpdateProfileViewModel.self)!
            let model = resolver.resolve(UpdateProfileModel.self)!

            view.viewModel = viewModel
            viewModel.model = model

            return view
        }

        container.register(UpdateProfileViewModel.self) { _ in
            UpdateProfileViewModel()
        }

        container.register(UpdateProfileModel.self) { resolver in
            UpdateProfileModel(service: resolver.resolve(MeServiceProtocol.self)!,
                               realtimeSyncService: resolver.resolve(MeRealtimeSyncService.self)!)
        }
    }
}
