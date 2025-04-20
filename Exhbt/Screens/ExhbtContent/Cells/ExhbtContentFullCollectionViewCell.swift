//
//  ExhbtContentFullCollectionViewCell.swift
//  Exhbt
//
//  Created by Adem Tarhan on 19.09.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class ExhbtContentFullCollectionViewCell: UICollectionViewCell {
    static var reuseIdentifier = "ExhbtContentFullCollectionViewCell"

    @IBOutlet var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension ExhbtContentFullCollectionViewCell: ExhbtContentProtocol {
    func update(withModel model: ExhbtContentDisplayModel) {
        imageView.loadImage(urlString: model.url)
    }
}
