//
//  GalleryGridCollectionViewCell.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/05/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class GalleryGridCollectionViewCell: UICollectionViewCell {
    static let resuseIdentifier = "GalleryGridCollectionViewCell"

    @IBOutlet var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.borderWidth = 1.0
    }

    func configure(_ model: DisplayModel) {
        guard let gallery = model as? GalleryDisplayModel else {
            // TODO: Add a placeholder?
            return
        }

        imageView.loadImage(withURL: gallery.photoURL)
        if gallery.mediaType == .video {
            imageView.addVideoIndicator()
        }
    }
}
