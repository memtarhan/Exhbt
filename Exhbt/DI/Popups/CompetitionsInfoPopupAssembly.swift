//
//  CompetitionsInfoPopupAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 16/10/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class CompetitionsInfoPopupAssembly: Assembly {
    func assemble(container: Container) {
        container.register(CompetitionsInfoPopup.self) { _ in
            let view = CompetitionsInfoPopup.instantiate()

            return view
        }
    }
}
