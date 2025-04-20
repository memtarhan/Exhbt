//
//  ExhbtDetailsAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 05/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class ExhbtDetailsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ExhbtDetailsViewController.self) { resolver in
            let view = ExhbtDetailsViewController.instantiate()
            let viewModel = resolver.resolve(ExhbtDetailsViewModel.self)!
            let model = resolver.resolve(ExhbtDetailsModel.self)!

            view.viewModel = viewModel
            viewModel.model = model

            return view
        }

        container.register(ExhbtDetailsViewModel.self) { _ in
            ExhbtDetailsViewModel()
        }

        container.register(ExhbtDetailsModel.self) { resolver in
            ExhbtDetailsModel(service: resolver.resolve(ExhbtServiceProtocol.self)!)
        }
    }
}
