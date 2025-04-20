//
//  ExhbtContentAssembly.swift
//  Exhbt
//
//  Created by Adem Tarhan on 18.09.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject

class ExhbtContentAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ExhbtContentViewController.self) { resolver in
            let view = ExhbtContentViewController.instantiate()
            let model = resolver.resolve(ExhbtContentModel.self)!
            let viewModel = resolver.resolve(ExhbtContentViewModel.self)!
            
            view.viewModel = viewModel
            viewModel.model = model
            return view
        }
        
        container.register(ExhbtContentModel.self) { resolver in
            ExhbtContentModel(exhbtService: resolver.resolve(ExhbtServiceProtocol.self)!)
        }
        container.register(ExhbtContentViewModel.self) { _ in
            ExhbtContentViewModel()
        }
    }
}
