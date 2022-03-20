//
//  Category.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 20/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

enum Category: String {
    case architecture
    case travel
    case animals
    case food
    case portrait

    var title: String {
        return rawValue.uppercased()
    }

    static let all: [Category] = [.architecture, .travel, .animals, .food, .portrait]
}
