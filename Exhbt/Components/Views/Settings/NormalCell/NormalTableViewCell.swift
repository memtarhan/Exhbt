//
//  NormalTableViewCell.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 10/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class NormalTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var separarorLine: UIView!
    
    static let identifier = "NormalTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
