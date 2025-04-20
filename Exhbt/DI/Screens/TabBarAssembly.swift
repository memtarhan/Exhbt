//
//  TabBarAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 21/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class TabBarAssembly: Assembly {
    func assemble(container: Container) {
        container.register(TabBarViewController.self) { resolver in
            let view = TabBarViewController()
            let viewModel = resolver.resolve(TabBarViewModel.self)

            view.viewModel = viewModel
            
            return view
        }

        container.register(TabBarViewModel.self) { resolver in
            TabBarViewModel(service: resolver.resolve(InvitationServiceProtocol.self)!,
                            meService: resolver.resolve(MeServiceProtocol.self)!)
        }
    }
}
