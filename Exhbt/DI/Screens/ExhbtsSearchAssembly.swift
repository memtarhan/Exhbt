//
//  ExhbtsSearchAssembly.swift
//  Exhbt
//
//  Created by Bekzod Rakhmatov on 16/06/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit
import Swinject

class ExhbtsSearchAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ExploreSearchViewController.self) { resolver in
            let view = ExploreSearchViewController.instantiate()
            let viewModel = resolver.resolve(ExploreSearchViewModel.self)!
            let model = resolver.resolve(ExhbtsModel.self)!
            view.viewModel = viewModel
            viewModel.model = model
            return view
        }
        container.register(ExploreSearchViewModel.self) { _ in
            ExploreSearchViewModel()
        }
        container.register(ExhbtsModel.self) { resolver in
            ExhbtsModel(service: resolver.resolve(ExhbtsServiceProtocol.self)!, tagService: resolver.resolve(TagServiceProtocol.self)!)
        }
    }
}
