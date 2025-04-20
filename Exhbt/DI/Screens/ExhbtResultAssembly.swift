//
//  ExhbtResultAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 30/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class ExhbtResultAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ExhbtResultViewController.self) { resolver in
            let view = ExhbtResultViewController.instantiate()
            let viewModel = resolver.resolve(ExhbtResultViewModel.self)!
            let model = resolver.resolve(ExhbtResultModel.self)!

            viewModel.model = model
            view.viewModel = viewModel

            return view
        }

        container.register(ExhbtResultViewModel.self) { _ in
            ExhbtResultViewModel()
        }

        container.register(ExhbtResultModel.self) { resolver in
            ExhbtResultModel(service: resolver.resolve(ExhbtServiceProtocol.self)!)
        }
    }
}
