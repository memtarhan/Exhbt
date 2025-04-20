//
//  ExhbtAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 29/08/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class ExhbtAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ExhbtViewController.self) { resolver in
            let view = ExhbtViewController.instantiate()
            let viewModel = resolver.resolve(ExhbtViewModel.self)!
            let model = resolver.resolve(ExhbtModel.self)!

            view.viewModel = viewModel
            viewModel.model = model
            
            return view
        }

        container.register(ExhbtViewModel.self) { _ in
            ExhbtViewModel()
        }

        container.register(ExhbtModel.self) { resolver in
            ExhbtModel(exhbtService: resolver.resolve(ExhbtServiceProtocol.self)!)
        }
    }
}
