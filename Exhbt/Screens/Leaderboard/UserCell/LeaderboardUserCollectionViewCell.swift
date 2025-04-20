//
//  LeaderboardUserCollectionViewCell.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 28/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class LeaderboardUserCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "LeaderboardUserCollectionViewCell"

    @IBOutlet var rankLabel: UILabel!
    @IBOutlet var profileImageView: CircleImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        rankLabel.layer.cornerRadius = rankLabel.frame.height / 2
    }

    func configure(withUser user: LeaderboardUserDisplayModel, shouldHideRank: Bool = false) {
        rankLabel.text = user.rankNumber
        usernameLabel.text = user.username
        scoreLabel.text = user.score

        rankLabel.textColor = user.rankType.hasWhiteText ? .white : .black
        rankLabel.backgroundColor = UIColor(named: user.rankType.colorName)

        profileImageView.backgroundColor = .systemBlue
        profileImageView.image = nil
        profileImageView.loadImage(urlString: user.photoURL)
        
        rankLabel.isHidden = shouldHideRank
    }
}
