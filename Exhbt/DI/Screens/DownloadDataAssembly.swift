//
//  DownloadDataAssembly.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 09/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit
import Swinject

class DownloadDataAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(DownloadDataViewController.self) { resolver in
            let view = DownloadDataViewController.instantiate()
            let viewModel = resolver.resolve(DownloadDataViewModel.self)
            view.viewModel = viewModel
            viewModel?.view = view
            return view
        }
        container.register(DownloadDataViewModel.self) { _ in
            DownloadDataViewModel()
        }
    }
}
