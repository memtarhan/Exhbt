//
//  UICollectionView+.swift
//  Exhbt
//
//  Created by Bekzod Rakhmatov on 21/05/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

extension UICollectionView {
    func deselectAllItems(animated: Bool = false) {
        for indexPath in indexPathsForSelectedItems ?? [] {
            deselectItem(at: indexPath, animated: animated)
        }
    }
}
