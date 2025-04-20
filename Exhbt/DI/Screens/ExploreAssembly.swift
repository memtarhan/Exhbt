//
//  ExploreAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 09/10/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class ExploreAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ExploreViewController.self) { resolver in
            let view = ExploreViewController()

            view.exhbtsViewController = resolver.resolve(ExhbtsViewController.self)!
            view.eventsViewController = resolver.resolve(EventsViewController.self)!
            return view
        }
    }
}
