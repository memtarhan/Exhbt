//
//  EventAssembly.swift
//  Exhbt
//
//  Created by Adem Tarhan on 30.09.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import Swinject
import SwiftUI

class EventsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(EventsViewController.self) { resolver in
            let view = EventsViewController.instantiate()
            let viewModel = resolver.resolve(EventsViewModel.self)!
            let model = resolver.resolve(EventsModel.self)!

            view.viewModel = viewModel
            view.filterViewController = UIHostingController(rootView: FilterView())
            viewModel.model = model
            
            return view
        }
        container.register(EventsViewModel.self) { _ in
            EventsViewModel()
        }

        container.register(EventsModel.self) { resolver in
            EventsModel(service: resolver.resolve(EventServiceProtocol.self)!,
                        meService: resolver.resolve(MeServiceProtocol.self)!)
        }
    }
}
