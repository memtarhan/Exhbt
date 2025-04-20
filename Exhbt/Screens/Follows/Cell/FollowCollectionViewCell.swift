//
//  FollowCollectionViewCell.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 06/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class FollowCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "FollowCollectionViewCell"

    @IBOutlet var imageView: CircleImageView!
    @IBOutlet var usernameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(_ model: DisplayModel) {
        guard let user = model as? FollowDisplayModel else {
            // TODO: Add a placeholder?
            return
        }

        imageView.loadImage(withURL: user.photoURL)
        usernameLabel.text = user.username
    }
}
