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

    @IBOutlet var statusContainerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        statusContainerView.layer.cornerRadius = 20
        statusContainerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class FeedsTableViewDiffableDataSource: UITableViewDiffableDataSource<String?, FeedEntity.Feed.ViewModel> {}

class CardView: UIView {
    override func layoutSubviews() {
        layer.cornerRadius = 20.0
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.7
    }
}
