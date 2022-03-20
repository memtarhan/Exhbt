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

    @IBOutlet var containerView: CardView!
    @IBOutlet var imagesStackView: UIStackView!
    @IBOutlet var categoryView: UIView!
    @IBOutlet var statusView: UIView!
    @IBOutlet var voteStatusContainerView: UIView!
    @IBOutlet var voteStatusImageView: UIImageView!
    @IBOutlet var voteStatusLabel: UILabel!

    static let cornerRadius: CGFloat = 24

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.backgroundColor = .white

        imagesStackView.layer.cornerRadius = FeedTableViewCell.cornerRadius
        imagesStackView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        categoryView.makeCircle()
        statusView.makeCircle()

        voteStatusContainerView.layer.cornerRadius = FeedTableViewCell.cornerRadius
        voteStatusContainerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
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
            let imageView = UIImageView(image: UIImage(named: image))
            imagesStackView.addArrangedSubview(imageView)
        }

        if viewModel.voted {
            voteStatusContainerView.backgroundColor = UIColor(named: "VoteStatus - Unvoted") // TODO: Move it to Colors
            voteStatusImageView.image = UIImage(named: "Vote")
            voteStatusLabel.text = "\(viewModel.voteCount!)"

        } else {
            voteStatusContainerView.backgroundColor = UIColor.systemBlue // TODO: Move it to Colors
            voteStatusImageView.image = UIImage(named: "VoteThumb")
            voteStatusLabel.text = "See and Vote"
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

extension UIView {
    func makeCircle() {
        layer.cornerRadius = frame.height / 2
    }
}
