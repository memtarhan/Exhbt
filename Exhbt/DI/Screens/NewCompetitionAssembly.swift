//
//  NewCompetitionAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/08/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class NewCompetitionAssembly: Assembly {
    func assemble(container: Container) {
        container.register(NewCompetitionViewController.self) { resolver in
            let view = NewCompetitionViewController.instantiate()
            let viewModel = resolver.resolve(NewCompetitionViewModel.self)!
            let model = resolver.resolve(NewCompetitionModel.self)!

            view.viewModel = viewModel
            viewModel.model = model

            return view
        }

        container.register(NewCompetitionViewModel.self) { _ in
            NewCompetitionViewModel()
        }

        container.register(NewCompetitionModel.self) { resolver in
            NewCompetitionModel(competitionService: resolver.resolve(CompetitionServiceProtocol.self)!,
                                exhbtService: resolver.resolve(ExhbtServiceProtocol.self)!,
                                realtimeSync: resolver.resolve(ExhbtsRealtimeSyncService.self)!,
                                meRealtimeSync: resolver.resolve(MeRealtimeSyncService.self)!)
        }
    }
}
