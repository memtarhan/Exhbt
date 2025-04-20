//
//  MeAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 12/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class MeAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MeViewController.self) { resolver in
            let view = MeViewController.instantiate()
            let viewModel = resolver.resolve(MeViewModel.self)!
            let model = resolver.resolve(MeModel.self)!

            viewModel.model = model
            view.viewModel = viewModel

            return view
        }

        container.register(MeViewModel.self) { _ in
            MeViewModel()
        }

        container.register(MeModel.self) { resolver in
            MeModel(service: resolver.resolve(MeServiceProtocol.self)!)
        }
    }
}
