//
//  UITableView.swift
//  Exhbt
//
//  Created by Bekzod Rakhmatov on 21/05/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

extension UITableView {
    func deselectAllRows(animated: Bool = false) {
        for indexPath in indexPathsForSelectedRows ?? [] {
            deselectRow(at: indexPath, animated: animated)
        }
    }
}
