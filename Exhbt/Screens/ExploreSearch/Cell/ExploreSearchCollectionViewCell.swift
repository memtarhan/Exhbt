//
//  ExploreSearchCollectionViewCell.swift
//  Exhbt
//
//  Created by Bekzod Rakhmatov on 19/06/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class ExploreSearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var profileImageView: CircleImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    static let reuseIdentifier = "ExploreSearchCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(_ model: ExploreUserDisplayModel) {
        profileImageView.backgroundColor = .systemBlue
        profileImageView.image = nil
        profileImageView.loadImage(urlString: model.profilePhoto)
        titleLabel.text = model.fullName
        profileImageView.isHidden = false
        subtitleLabel.text = model.username
    }
}
