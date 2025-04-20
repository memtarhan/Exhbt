//
//  TitleIconCell.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 10/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class TitleIconTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var separarorLine: UIView!
    
    static let identifier = "TitleIconTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
