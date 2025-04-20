//
//  PrizesAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 16/01/2024.
//  Copyright © 2024 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class PrizesAssembly: Assembly {
    func assemble(container: Container) {
        container.register(PrizesViewController.self) { resolver in
            let view = PrizesViewController.instantiate()
            let viewModel = resolver.resolve(PrizesViewModel.self)!
            let model = resolver.resolve(PrizesModel.self)!

            viewModel.model = model
            view.viewModel = viewModel

            return view
        }

        container.register(PrizesViewModel.self) { _ in
            PrizesViewModel()
        }

        container.register(PrizesModel.self) { resolver in
            PrizesModel(meService: resolver.resolve(MeServiceProtocol.self)!,
                        userService: resolver.resolve(UserServiceProtocol.self)!)
        }
    }
}
