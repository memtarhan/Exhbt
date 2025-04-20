//
//  VoteStyleViewerAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 28/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Swinject
import UIKit

class VoteStyleViewerAssembly: Assembly {
    func assemble(container: Container) {
        container.register(VoteStyleViewer.self) { resolver in
            let view = VoteStyleViewer.instantiate()
            view.userService = resolver.resolve(ProfileServiceProtocol.self)!

            return view
        }
    }
}
