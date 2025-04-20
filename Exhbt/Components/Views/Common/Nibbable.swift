//
//  Nibbable.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 12/06/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

protocol Nibbable {
    static func instantiate() -> Self
}

extension Nibbable where Self: UIViewController {
    /**
     Instantiates a view controller from a nib with the same name
     */
    static func instantiate() -> Self {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".")[1]

        return Self(nibName: className, bundle: nil)
    }
}

protocol CellIdentifiable {
    static var identifier: String { get }
}

extension CellIdentifiable where Self: UITableViewCell {
    static var identifier: String {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".")[1]
        return className
    }
}

extension CellIdentifiable where Self: UICollectionViewCell {
    static var identifier: String {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".")[1]
        return className
    }
}
