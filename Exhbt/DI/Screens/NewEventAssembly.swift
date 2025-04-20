//
//  NewEvent.swift
//  Exhbt
//
//  Created by Adem Tarhan on 27.09.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import Swinject

class NewEventAssembly: Assembly {
    func assemble(container: Container) {
        container.register(NewEventViewController.self) { resolver in
            let view = NewEventViewController.instantiate()
            let viewModel = resolver.resolve(NewEventViewModel.self)!
            let model = resolver.resolve(NewEventModel.self)!

            view.viewModel = viewModel
            viewModel.model = model

            return view
        }

        container.register(NewEventViewModel.self) { _ in
            NewEventViewModel()
        }

        container.register(NewEventModel.self) { resolver in
            NewEventModel(service: resolver.resolve(EventServiceProtocol.self)!,
                          meService: resolver.resolve(MeServiceProtocol.self)!,
                          realtimeSync: resolver.resolve(EventsRealtimeSyncService.self)!,
                          meRealtimeSync: resolver.resolve(MeRealtimeSyncService.self)!)
        }
    }
}
