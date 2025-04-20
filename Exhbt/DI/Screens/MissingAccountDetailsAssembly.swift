//
//  MissingAccountDetailsAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class MissingAccountDetailsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MissingAccountDetailsViewController.self) { resolver in
            let view = MissingAccountDetailsViewController.instantiate()
            let viewModel = resolver.resolve(MissingAccountDetailsViewModel.self)!
            let model = resolver.resolve(MissingAccountDetailsModel.self)!

            view.viewModel = viewModel
            viewModel.model = model

            return view
        }
        container.register(MissingAccountDetailsViewModel.self) { _ in
            MissingAccountDetailsViewModel()
        }
        container.register(MissingAccountDetailsModel.self) { resolver in
            MissingAccountDetailsModel(service: resolver.resolve(MeServiceProtocol.self)!,
                                       realtimeSyncService: resolver.resolve(MeRealtimeSyncService.self)!)
        }
    }
}
