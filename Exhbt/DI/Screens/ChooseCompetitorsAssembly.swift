//
//  ChooseCompetitorsAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 06/10/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class ChooseCompetitorsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ChooseCompetitorsViewController.self) { resolver in
            let view = ChooseCompetitorsViewController.instantiate()
            let viewModel = resolver.resolve(ChooseCompetitorsViewModel.self)!
            let model = resolver.resolve(ChooseCompetitorsModel.self)!

            view.viewModel = viewModel
            viewModel.model = model

            return view
        }

        container.register(ChooseCompetitorsViewModel.self) { _ in
            ChooseCompetitorsViewModel()
        }

        container.register(ChooseCompetitorsModel.self) { resolver in
            ChooseCompetitorsModel(exhbtService: resolver.resolve(ExhbtServiceProtocol.self)!, profileService: resolver.resolve(ProfileServiceProtocol.self)!)
        }
    }
}
