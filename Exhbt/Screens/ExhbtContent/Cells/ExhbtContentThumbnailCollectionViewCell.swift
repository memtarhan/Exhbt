//
//  ExhbtContentThumbnailCollectionViewCell.swift
//  Exhbt
//
//  Created by Adem Tarhan on 19.09.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

protocol ExhbtContentProtocol {
    func update(withModel model: ExhbtContentDisplayModel)
}

class ExhbtContentThumbnailCollectionViewCell: UICollectionViewCell {
    static var reuseIdentifier = "ExhbtContentThumbnailCollectionViewCell"

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var coverView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        coverView.layer.cornerRadius = 4
        imageView.layer.cornerRadius = 4
    }
    
    
    override var isSelected: Bool {
        didSet{
            coverView.isHidden = isSelected
        }
    }
    
    
}

extension ExhbtContentThumbnailCollectionViewCell: ExhbtContentProtocol {
    func update(withModel model: ExhbtContentDisplayModel) {
        imageView.loadImage(urlString: model.url)
    }
}
