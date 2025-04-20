//
//  EventDetailsAssembly.swift
//  Exhbt
//
//  Created by Adem Tarhan on 1.10.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import Swinject

class XEventDetailsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(XEventDetailsViewController.self) { resolver in
            let view = XEventDetailsViewController.instantiate()
            let viewModel = resolver.resolve(EventDetailsViewModel.self)!
            let model = resolver.resolve(EventDetailsModel.self)!

            view.viewModel = viewModel
            viewModel.model = model

            return view
        }

        container.register(EventDetailsModel.self) { resolver in
            EventDetailsModel(service: resolver.resolve(EventServiceProtocol.self)!,
                              meService: resolver.resolve(MeServiceProtocol.self)!)
        }

        container.register(EventDetailsViewModel.self) { _ in
            EventDetailsViewModel()
        }
    }
}
