//
//  CategoryCollectionViewCell.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 21/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var chooseButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 12.0
    }

    func configure(_ model: NewExhbtModel.CategoryModel) {
        imageView.image = UIImage(named: model.image)
        titleLabel.text = model.title
    }
}

class CategoryCollectionViewDiffableDataSource: UICollectionViewDiffableDataSource<CategorySection, NewExhbtModel.CategoryModel> {}

enum CategorySection: CaseIterable {
    case category
}
