//
//  NewCompetitionStatusAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 06/10/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class NewCompetitionStatusAssembly: Assembly {
    func assemble(container: Container) {
        container.register(NewCompetitionStatusViewController.self) { _ in
            let view = NewCompetitionStatusViewController.instantiate()

            return view
        }
    }
}
