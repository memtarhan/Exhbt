//
//  Category.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 21/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Foundation

enum Category: String, CaseIterable, Equatable {
    case architecture
    case food
    case beauty
    case animals
    case art
    case auto
    case fashion
    case fitness
    case nature
    case sports
    case all

    var image: String { "\(title)Category" }
    var title: String { rawValue.capitalized }
    var id: Int { Category.allCases.firstIndex(of: self)! + 1 }
    
    // To display in UI
    static var displayableList: [Category] {
        var all = Category.allCases
        let last = all.removeLast()
        all.insert(last, at: 0)
        return all
    }
}
