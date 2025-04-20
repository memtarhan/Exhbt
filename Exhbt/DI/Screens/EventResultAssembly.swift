//
//  EventResultAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 20/11/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import Swinject

class EventResultAssembly: Assembly {
    func assemble(container: Container) {
        container.register(EventResultViewController.self) { resolver in
            let view = EventResultViewController.instantiate()

            let viewModel = resolver.resolve(EventResultViewModel.self)!
            let model = resolver.resolve(EventResultModel.self)!

            view.viewModel = viewModel
            viewModel.model = model

            return view
        }

        container.register(EventResultViewModel.self) { _ in
            EventResultViewModel()
        }

        container.register(EventResultModel.self) { resolver in
            EventResultModel(service: resolver.resolve(EventServiceProtocol.self)!)
        }
    }
}
