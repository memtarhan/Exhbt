//
//  FeedTableViewCell.swift
//  Exhbt
//
//  Created Mehmet Tarhan on 04/03/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    static let reuseIdentifier = "Feed"
    static let nibIdentifier = "FeedTableViewCell"

    @IBOutlet var imagesStackView: UIStackView!
    @IBOutlet var statusContainerView: UIView!

    static let cornerRadius: CGFloat = 24

    override func awakeFromNib() {
        super.awakeFromNib()

        imagesStackView.layer.cornerRadius = FeedTableViewCell.cornerRadius
        imagesStackView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        statusContainerView.layer.cornerRadius = FeedTableViewCell.cornerRadius
        statusContainerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // TODO: Optimize this part
        imagesStackView.arrangedSubviews.forEach { subview in
            self.imagesStackView.removeArrangedSubview(subview)
        }
    }

    func configure(_ viewModel: FeedEntity.Feed.ViewModel) {
        viewModel.images.forEach { image in
            let imageView = UIImageView(image: image)
            imagesStackView.addArrangedSubview(imageView)
        }
    }
}

class FeedsTableViewDiffableDataSource: UITableViewDiffableDataSource<String?, FeedEntity.Feed.ViewModel> {}

class CardView: UIView {
    override func layoutSubviews() {
        layer.cornerRadius = FeedTableViewCell.cornerRadius
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.7
    }
}
