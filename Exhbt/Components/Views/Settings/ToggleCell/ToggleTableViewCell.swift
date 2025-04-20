//
//  ToggleTableViewCell.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 10/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class ToggleTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var toggle: UISwitch!
    @IBOutlet var separarorLine: UIView!
    
    static let identifier = "ToggleTableViewCell"
    weak var delegate: ToggleTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func didTapToggle() {
        delegate?.didTapToggleTableViewCell(self)
    }
}

protocol ToggleTableViewCellDelegate: AnyObject {
    func didTapToggleTableViewCell(_ cell: ToggleTableViewCell)
}
