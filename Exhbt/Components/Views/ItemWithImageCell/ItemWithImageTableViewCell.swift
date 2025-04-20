//
//  ItemWithImageTableViewCell.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 08/10/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

class ItemWithImageTableViewCell: UITableViewCell, CellIdentifiable {
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        photoImageView.layer.cornerRadius = photoImageView.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected { backgroundColor = UIColor(named: "SelectedContactBackgroundColor") }
        else { backgroundColor = .clear }
    }
}
