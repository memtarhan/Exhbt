//
//  NewExhbtAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 21/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class NewExhbtAssembly: Assembly {
    func assemble(container: Container) {
        container.register(NewExhbtViewController.self) { resolver in
            let view = NewExhbtViewController.instantiate()
            let viewModel = resolver.resolve(NewExhbtViewModel.self)!
            let model = resolver.resolve(NewExhbtModel.self)!

            view.viewModel = viewModel
            viewModel.model = model

            return view
        }

        container.register(NewExhbtViewModel.self) { _ in
            NewExhbtViewModel()
        }

        container.register(NewExhbtModel.self) { resolver in
            NewExhbtModel(exhbtService: resolver.resolve(ExhbtServiceProtocol.self)!,
                          competitionService: resolver.resolve(CompetitionServiceProtocol.self)!,
                          realtimeSync: resolver.resolve(ExhbtsRealtimeSyncService.self)!,
                          meRealtimeSync: resolver.resolve(MeRealtimeSyncService.self)!)
        }
    }
}
