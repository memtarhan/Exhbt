//
//  HomeAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 20/06/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI
import Swinject
import UIKit

class HomeAssembly: Assembly {
    func assemble(container: Container) {
        container.register(HomeViewController.self) { resolver in
            let view = HomeViewController()
            let viewModel = resolver.resolve(HomeViewModel.self)!
            let model = resolver.resolve(HomeModel.self)!

            viewModel.model = model

            view.viewModel = viewModel
            view.feedsViewController = resolver.resolve(FeedsViewController.self)!
            view.flashViewController = UIHostingController(rootView: FlashView())

            return view
        }

        container.register(HomeViewModel.self) { _ in
            HomeViewModel()
        }

        container.register(HomeModel.self) { resolver in
            HomeModel(meService: resolver.resolve(MeServiceProtocol.self)!)
        }
    }
}
