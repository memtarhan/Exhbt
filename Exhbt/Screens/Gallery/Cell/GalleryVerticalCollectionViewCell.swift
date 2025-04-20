//
//  GalleryVerticalCollectionViewCell.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 16/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class GalleryVerticalCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "GalleryVerticalCollectionViewCell"

    @IBOutlet var submissionImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with model: GalleryDisplayModel) {
        submissionImageView.loadImage(withURL: model.photoURL)
    }
}
