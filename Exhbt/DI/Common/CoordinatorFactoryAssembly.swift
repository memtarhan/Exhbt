//
//  CoordinatorFactoryAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 22/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation
import Swinject

class CoordinatorFactoryAssembly: Assembly {
    private let assembler: Assembler

    init(assembler: Assembler) {
        self.assembler = assembler
    }

    func assemble(container: Container) {
        container.register(ViewControllerFactoryProtocol.self) { _ in
            ViewControllerFactory(assembler: self.assembler)
        }
    }
}
