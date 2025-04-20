//
//  GalleryGridAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class GalleryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(GalleryVerticalViewController.self) { resolver in
            let view = GalleryVerticalViewController.instantiate()
            let _ = resolver.resolve(GalleryGridViewModel.self)!
            let _ = resolver.resolve(GalleryGridModel.self)!

            return view
        }

        // We might need these in future
        container.register(GalleryGridViewModel.self) { _ in
            GalleryGridViewModel()
        }

        container.register(GalleryGridModel.self) { resolver in
            GalleryGridModel(service: resolver.resolve(ProfileServiceProtocol.self)!)
        }
    }
}
