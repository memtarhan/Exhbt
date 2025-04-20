//
//  SingleCompetitorTableViewCell.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 04/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Kingfisher
import UIKit

class SingleCompetitorTableViewCell: UITableViewCell {
    static let reuseIdentifier = "SingleCompetitorTableViewCell"

    @IBOutlet var competitorImageView: CompetitorPhotoView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var exhbtUserLabel: UILabel!
    @IBOutlet var moreButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func update(withItem item: SingleExhbtCompetitorItem, status: CompetitorAcceptanceStatus) {
        nameLabel.text = item.name
        exhbtUserLabel.isHidden = !item.isExhbtUser

        if let url = item.photo {
            competitorImageView.imageView.loadImage(urlString: url)

        } else {
            competitorImageView.imageView.image = UIImage(systemName: "person")
        }

        competitorImageView.update(withStatus: status)
    }
}
