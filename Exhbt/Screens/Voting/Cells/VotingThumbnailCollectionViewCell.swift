//
//  VotingThumbnailCollectionViewCell.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class VotingThumbnailCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "VotingThumbnailCollectionViewCell"

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var coverView: UIView!
    @IBOutlet var thumbImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 4
        coverView.layer.cornerRadius = 4
        thumbImageView.image = nil
    }

    override var isSelected: Bool {
        didSet {
            coverView.isHidden = isSelected
        }
    }
}

extension VotingThumbnailCollectionViewCell: VotingCellProtocol {
    func update(withModel model: CompetitionDisplayModel) {
        thumbImageView.isHidden = !model.voted
        thumbImageView.image = UserSettings.shared.voteStyle?.thumbsImage

        imageView.loadImage(urlString: model.content.thumbnailURL)
    }
}
