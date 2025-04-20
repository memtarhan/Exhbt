//
//  ExhbtCollectionViewCell.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 30/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class ExhbtCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ExhbtCollectionViewCell"

    @IBOutlet var containerView: ExhbtPreviewView!

    var id: Int?

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.backgroundColor = .clear
    }

    func configure(_ model: DisplayModel) {
        id = model.id
        guard let exhbt = model as? ExhbtPreviewDisplayModel else {
            // TODO: Add a placeholder
            return
        }
        containerView.update(withModel: exhbt, alreadyInEditMode: exhbt.isOwn)
    }
}
