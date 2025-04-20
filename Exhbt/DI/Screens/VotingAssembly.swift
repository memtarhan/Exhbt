//
//  VotingAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class VotingAssembly: Assembly {
    func assemble(container: Container) {
        container.register(VotingViewController.self) { resolver in
            let view = VotingViewController.instantiate()
            let viewModel = resolver.resolve(VotingViewModel.self)!
            let model = resolver.resolve(VotingModel.self)!

            viewModel.model = model
            view.viewModel = viewModel

            return view
        }

        container.register(VotingViewModel.self) { _ in
            VotingViewModel()
        }

        container.register(VotingModel.self) { resolver in
            VotingModel(exhbtService: resolver.resolve(ExhbtServiceProtocol.self)!,
                        competitionService: resolver.resolve(CompetitionServiceProtocol.self)!,
                        meService: resolver.resolve(MeServiceProtocol.self)!)
        }
    }
}
