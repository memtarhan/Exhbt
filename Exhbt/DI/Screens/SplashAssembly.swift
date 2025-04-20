//
//  SplashAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/09/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class SplashAssembly: Assembly {
    func assemble(container: Container) {
        container.register(SplashViewController.self) { resolver in
            let view = SplashViewController.instantiate()

            let viewModel = resolver.resolve(SplashViewModel.self)!
            let model = resolver.resolve(SplashModel.self)!

            viewModel.model = model
            view.viewModel = viewModel

            return view
        }

        container.register(SplashViewModel.self) { _ in
            SplashViewModel()
        }

        container.register(SplashModel.self) { resolver in
            SplashModel(meService: resolver.resolve(MeServiceProtocol.self)!)
        }
    }
}
