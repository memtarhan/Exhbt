//
//  EventDetailsCollectionViewCell.swift
//  Exhbt
//
//  Created by Adem Tarhan on 5.10.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

class XEventDetailsCollectionViewCell: UICollectionViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView!

    @IBOutlet var disLikeView: UIView!
    @IBOutlet var likeView: UIView!
    static let reuseIdentifier = "EventDetailsCollectionViewCell"

    private var toogle = false

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        setGesture()
    }

    // MARK: - Actions

    @objc func didTapDisLike(_ gesture: UIGestureRecognizer) {
        toogle = !toogle

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            debugLog(self, "\(toogle)")
            switch swipeGesture.direction {
            case .left:
                likeView.isHidden = toogle ? false : true
                disLikeView.isHidden = toogle ? true : false
                toogle = false
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] _ in
                    likeView.isHidden = true
                    imageView.layer.borderWidth = 2
                    imageView.layer.borderColor = UIColor(named: "EventGreenBorder")?.cgColor
                }
            case .right:
                disLikeView.isHidden = toogle ? false : true
                likeView.isHidden = toogle ? true : false
                toogle = false
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] _ in
                    disLikeView.isHidden = true
                    imageView.layer.borderWidth = 2
                    imageView.layer.borderColor = UIColor(named: "EventRedBorder")?.cgColor
                }
            default:
                debugLog(self, #function)
            }
        }
    }

    func configure(_ model: DisplayModel) {
        guard let post = model as? EventPostDisplayModel else {
            // TODO: Add a placeholder
            return
        }

        imageView.loadImage(urlString: post.media.url)
    }
}

extension XEventDetailsCollectionViewCell {
    func setup() {
        containerView.layer.cornerRadius = 12
        layer.cornerRadius = 12
        imageView.layer.cornerRadius = 12
    }

    // MARK: - Set Gesture

    func setGesture() {
        let dislikeSwipe = UISwipeGestureRecognizer(target: self, action: #selector(didTapDisLike))
        dislikeSwipe.direction = .right

        let likeSwipe = UISwipeGestureRecognizer(target: self, action: #selector(didTapDisLike))
        likeSwipe.direction = .left

        containerView.addGestureRecognizer(dislikeSwipe)
        containerView.addGestureRecognizer(likeSwipe)
    }
}
