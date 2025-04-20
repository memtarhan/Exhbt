//
//  SingleSubmissionCollectionViewCell.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 04/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Kingfisher
import UIKit

class SingleSubmissionCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "SingleSubmissionCollectionViewCell"

    @IBOutlet var coverView: UIView!
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var voteCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        coverView.layer.cornerRadius = 6
    }

    func configure(withModel model: SingleExhbtSubmissionModel) {
        voteCountLabel.text = "\(model.voteCount)"

        coverImageView.loadImage(urlString: model.photo)
    }
}
