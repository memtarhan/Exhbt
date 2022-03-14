//
//  GalleryImageCell.swift
//  Exhbt
//
//  Created by Steven Worrall on 5/19/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class GalleryImageCell: UICollectionViewCell {
    var imageView: CustomImageView?
    
    func set(_ imageID: String) {
        let customImageView = CustomImageView(
            imageID: imageID,
            sizes: ImageSize.smallest(.tiny)
        )
        customImageView.contentMode = .scaleAspectFill
        customImageView.layer.masksToBounds = true
        addSubview(customImageView)
        customImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.imageView = customImageView
    }
}
