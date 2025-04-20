//
//  FreeSpotTableViewCell.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 14/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class FreeSpotTableViewCell: UITableViewCell {
    static let reuseIdentifier = "FreeSpotTableViewCell"

    @IBOutlet var indexCoverView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        indexCoverView.layer.cornerRadius = 24
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func update(withTitle title: String, name: String) {
        titleLabel.text = title
        nameLabel.text = name
    }
}
