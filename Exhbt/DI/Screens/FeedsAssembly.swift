//
//  FeedsAssembly.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 22/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class FeedsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(FeedsViewController.self) { resolver in
            let view = FeedsViewController.instantiate()
            let viewModel = resolver.resolve(FeedsViewModel.self)!
            let model = resolver.resolve(FeedsModel.self)!

            view.viewModel = viewModel
            viewModel.model = model

            return view
        }

        container.register(FeedsViewModel.self) { _ in
            FeedsViewModel()
        }

        container.register(FeedsModel.self) { resolver in
            FeedsModel(service: resolver.resolve(FeedsServiceProtocol.self)!)
        }
    }
}
