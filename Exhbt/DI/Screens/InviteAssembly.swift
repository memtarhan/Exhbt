//
//  InviteAssembly.swift
//  Exhbt
//
//  Created by Adem Tarhan on 7.10.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Foundation
import Swinject

class InviteAssembly: Assembly{
    func assemble(container: Container) {
        container.register(InviteViewController.self) { resolver in
            let view = InviteViewController.instantiate()
            var viewModel = resolver.resolve(InviteViewModel.self)!
            var model = resolver.resolve(InviteModel.self)!
            
            view.viewModel = viewModel
            viewModel.model = model
            
            
            return view
        }
        
        container.register(InviteViewModel.self) { _ in
            InviteViewModel()
        }
        
        container.register(InviteModel.self) { resolver in
            InviteModel(exhbtService: resolver.resolve(EventServiceProtocol.self)!, profileService: resolver.resolve(ProfileServiceProtocol.self)!)
        }
    }
}
