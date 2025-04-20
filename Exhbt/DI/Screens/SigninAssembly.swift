//
//  SigninAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 19/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class SigninAssembly: Assembly {
    func assemble(container: Container) {
        container.register(SigninViewController.self) { resolver in
            let view = SigninViewController.instantiate()

            let viewModel = resolver.resolve(SigninViewModel.self)!
            let model = resolver.resolve(SigninModel.self)!

            view.viewModel = viewModel
            viewModel.model = model

            return view
        }

        container.register(SigninViewModel.self) { _ in
            SigninViewModel()
        }

        container.register(SigninModel.self) { resolver in
            SigninModel(authService: resolver.resolve(AuthServiceProtocol.self)!)
        }
    }
}
