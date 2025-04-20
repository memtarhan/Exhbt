//
//  NewExhbtSetupAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 05/08/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class NewExhbtSetupAssembly: Assembly {
    func assemble(container: Container) {
        container.register(NewExhbtSetupViewController.self) { resolver in
            let view = NewExhbtSetupViewController.instantiate()
            let viewModel = resolver.resolve(NewExhbtViewModel.self)!
            let model = resolver.resolve(NewExhbtModel.self)!

            view.viewModel = viewModel
            viewModel.model = model
            view.viewModel = viewModel
            
            return view
        }
    }
}
