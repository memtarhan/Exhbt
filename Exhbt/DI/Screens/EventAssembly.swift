//
//  EventAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 02/01/2024.
//  Copyright © 2024 Exhbt LLC. All rights reserved.
//

import Foundation
import SwiftUI
import Swinject

class EventAssembly: Assembly {
    func assemble(container: Container) {
        container.register(EventViewController.self) { resolver in
            let view = EventViewController.instantiate()
            let viewModel = resolver.resolve(EventViewModel.self)!
            let model = resolver.resolve(EventModel.self)!

            view.viewModel = viewModel
            viewModel.model = model

            return view
        }
        container.register(EventViewModel.self) { _ in
            EventViewModel()
        }

        container.register(EventModel.self) { resolver in
            EventModel(service: resolver.resolve(EventServiceProtocol.self)!,
                       meService: resolver.resolve(MeServiceProtocol.self)!)
        }
    }
}
