//
//  NewPostAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 16/10/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class NewPostAssembly: Assembly {
    func assemble(container: Container) {
        container.register(NewPostViewController.self) { resolver in
            let view = NewPostViewController.instantiate()
            let viewModel = resolver.resolve(NewPostViewModel.self)!
            let model = resolver.resolve(NewPostModel.self)!

            viewModel.model = model
            view.viewModel = viewModel

            return view
        }

        container.register(NewPostViewModel.self) { _ in
            NewPostViewModel()
        }

        container.register(NewPostModel.self) { resolver in
            NewPostModel(service: resolver.resolve(EventServiceProtocol.self)!,
                         meService: resolver.resolve(MeServiceProtocol.self)!)
        }
    }
}
