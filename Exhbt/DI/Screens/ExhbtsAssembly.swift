//
//  ExploreAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 11/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class ExhbtsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ExhbtsViewController.self) { resolver in
            let view = ExhbtsViewController.instantiate()
            let viewModel = resolver.resolve(ExhbtsViewModel.self)!
            let model = resolver.resolve(ExhbtsModel.self)!
            view.viewModel = viewModel
            viewModel.model = model
            return view
        }
        container.register(ExhbtsViewModel.self) { _ in
            ExhbtsViewModel()
        }
        container.register(ExhbtsModel.self) { resolver in
            ExhbtsModel(service: resolver.resolve(ExhbtsServiceProtocol.self)!, tagService: resolver.resolve(TagServiceProtocol.self)!)
        }
    }
}
