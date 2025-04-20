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
    var delegate: FeedTableViewCellDelegate?

    @IBOutlet var containerView: CardView!
    @IBOutlet var statusView: UIView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var animationView: Spinner!
    @IBOutlet var statusLiveView: UILabel!
    @IBOutlet var statusImageView: UIImageView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var voteStatusContainerView: UIView!
    @IBOutlet var voteStatusImageView: UIImageView!
    @IBOutlet var voteStatusLabel: UILabel!
    @IBOutlet var imagesContentView: HorizontalPhotosView!

    // TODO: Move this to LayoutProperties
    static let cornerRadius: CGFloat = 24

    private var model: FeedPreviewDisplayModel?

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.backgroundColor = .white
        statusView.makeCircle()
        voteStatusContainerView.layer.cornerRadius = FeedTableViewCell.cornerRadius
        voteStatusContainerView.layer.maskedCorners = [
            .layerMaxXMaxYCorner,
            .layerMinXMaxYCorner,
        ]
        setLiveAnimation()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setLiveAnimation() {
        animationView.color = .red
    }

    func playLiveAnimation() {
        if model != nil {
            animationView.isHidden = false
            animationView.startRefreshing()
        }
    }

    func stopLiveAnimation() {
        if model != nil {
            animationView.isHidden = true
            animationView.stopRefreshing()
        }
    }

    @objc private func didTapCategory(_ sender: UITapGestureRecognizer) {
    }

    func configure(_ model: FeedPreviewDisplayModel) {
        self.model = model

        statusLabel.text = model.timeLeft
        statusLiveView.isHidden = false
        statusLabel.isHidden = false
        statusImageView.isHidden = model.timeLeft == ""
        statusImageView.image = UIImage(named: "Dot")
        statusImageView.tintColor = .black
        playLiveAnimation()

        descriptionLabel.attributedText = model.description.asHashtagText

        if model.voted {
            voteStatusContainerView.backgroundColor = .unvotedStatus
            voteStatusImageView.image = UIImage(named: "Vote")
            voteStatusLabel.text = "\(model.voteCount)"

        } else {
            voteStatusContainerView.backgroundColor = .votedStatus
            voteStatusImageView.image = UIImage(named: "VoteThumb")
            voteStatusLabel.text = "See and Vote"
        }

        UIView.animate(withDuration: 1.0) {
            self.containerView.alpha = 1
        }

        /// - Loading images
        imagesContentView.color = model.voted ? .unvotedStatus : .votedStatus
        imagesContentView.id = model.id
        imagesContentView.update(models: model.media)
    }
}

protocol FeedTableViewCellDelegate {
    func feedTableViewCell(didSelectCategory category: Category)
    func feedTableViewCell(didTapPicture image: UIImage?)
}

class FeedsTableViewDiffableDataSource: UITableViewDiffableDataSource<FeedsSection, FeedPreviewDisplayModel> {}

class CardView: UIView {
    override func layoutSubviews() {
        layer.cornerRadius = FeedTableViewCell.cornerRadius
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.7
    }
}


