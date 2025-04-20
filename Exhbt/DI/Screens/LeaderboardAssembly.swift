//
//  LeaderboardAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 11/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class LeaderboardAssembly: Assembly {
    func assemble(container: Container) {
        container.register(LeaderboardViewController.self) { resolver in
            let view = LeaderboardViewController()
            let viewModel = resolver.resolve(LeaderboardViewModel.self)!
            let model = resolver.resolve(LeaderboardModel.self)!

            view.viewModel = viewModel
            viewModel.model = model

            return view
        }

        container.register(LeaderboardViewModel.self) { _ in
            LeaderboardViewModel()
        }

        container.register(LeaderboardModel.self) { resolver in
            LeaderboardModel(service: resolver.resolve(LeaderboardServiceProtocol.self)!, tagService: resolver.resolve(TagServiceProtocol.self)!)
        }
    }
}
