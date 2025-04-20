//
//  CategorySmallCollectionViewCell.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 28/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class CategorySmallCollectionViewCell: UICollectionViewCell {
    static let resuseIdentifier = "CategorySmallCollectionViewCell"

    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 12

        containerView.layer.borderWidth = 2.0
        containerView.layer.borderColor = UIColor.clear.cgColor
    }

    override var isSelected: Bool {
        didSet {
            containerView.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        }
    }

    func configure(_ model: DisplayModel) {
        guard let category = model as? CategoryDisplayModel else {
            // TODO: Add a placeholder?
            return
        }
        imageView.image = UIImage(named: category.imageName)
        titleLabel.text = category.title
    }
}

class CategorySmallCollectionViewDiffableDataSource: UICollectionViewDiffableDataSource<CategorySmallSection, CategoryDisplayModel> {}

enum CategorySmallSection: CaseIterable {
    case category
}
