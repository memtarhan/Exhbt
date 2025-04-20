//
//  LinkTableViewCell.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 11/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class LinkTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var separarorLine: UIView!
    
    static let identifier = "LinkTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
