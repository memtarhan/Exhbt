//
//  VotesAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 20/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class VotesAssembly: Assembly {
    func assemble(container: Container) {
        container.register(VotesViewController.self) { resolver in
            let view = VotesViewController.instantiate()
            let viewModel = resolver.resolve(VotesViewModel.self)!
            let model = resolver.resolve(VotesModel.self)!

            viewModel.model = model
            view.viewModel = viewModel

            return view
        }

        container.register(VotesViewModel.self) { _ in
            VotesViewModel()
        }

        container.register(VotesModel.self) { resolver in
            VotesModel(service: resolver.resolve(MeServiceProtocol.self)!,
                       userService: resolver.resolve(UserServiceProtocol.self)!)
        }
    }
}
