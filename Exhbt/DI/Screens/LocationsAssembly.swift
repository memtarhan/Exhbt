//
//  LocationsAssembly.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 15/10/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import SwiftUI
import Swinject
import UIKit

class LocationsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(LocationsViewController.self) { _ in
            let view = LocationsViewController()

            return view
        }
    }
}
