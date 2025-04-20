//
//  NewExhbtPopupAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 25/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class NewExhbtPopupAssembly: Assembly {
    func assemble(container: Container) {
        container.register(NewExhbtPopup.self) { _ in
            let view = NewExhbtPopup.instantiate()

            return view
        }
    }
}
