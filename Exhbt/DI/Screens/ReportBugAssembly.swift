//
//  ReportBugAssembly.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 10/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit
import Swinject

class ReportBugAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(ReportBugViewController.self) { resolver in
            let view = ReportBugViewController.instantiate()
            let viewModel = resolver.resolve(ReportBugViewModel.self)
            view.viewModel = viewModel
            viewModel?.view = view
            return view
        }
        container.register(ReportBugViewModel.self) { _ in
            ReportBugViewModel()
        }
    }
}
