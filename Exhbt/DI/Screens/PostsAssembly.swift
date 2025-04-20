//
//  PostsAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI
import Swinject
import UIKit

class PostsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(PostsViewController.self) { resolver in
            let view = PostsViewController.instantiate()
            let viewModel = resolver.resolve(PostsViewModel.self)!
            let model = resolver.resolve(PostsModel.self)!

            viewModel.model = model
            view.viewModel = viewModel

            return view
        }

        container.register(PostsViewModel.self) { _ in
            PostsViewModel()
        }

        container.register(PostsModel.self) { resolver in
            PostsModel(service: resolver.resolve(PostsServiceProtocol.self)!,
                       eventService: resolver.resolve(EventServiceProtocol.self)!)
        }
    }
}
