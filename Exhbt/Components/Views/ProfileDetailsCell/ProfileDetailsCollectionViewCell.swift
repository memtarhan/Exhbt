//
//  ProfileDetailsCollectionViewCell.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 29/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Kingfisher
import SwiftUI
import UIKit

protocol ProfileDetailsDelegate: AnyObject {
    func profileDetails(didFollowUser user: ProfileDetailsDisplayModel)
    func profileDetails(didUnfollowUser user: ProfileDetailsDisplayModel)
    func profileDetails(willViewPrizes forUser: ProfileDetailsDisplayModel)
    func profileDetails(willViewVotes forUser: ProfileDetailsDisplayModel)
    func profileDetails(willViewFollowers forUser: ProfileDetailsDisplayModel)
    func profileDetails(willViewFollowings forUser: ProfileDetailsDisplayModel)
    func profileDetails(willViewProfilePhoto forUser: ProfileDetailsDisplayModel)
    func navigateToEdit()
}

class ProfileDetailsCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ProfileDetailsCollectionViewCell"

    @IBOutlet var containerView: UIView!
    @IBOutlet var profileImageView: CircleImageView!
    @IBOutlet var fullNameLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var bioLabel: UILabel!
    @IBOutlet var coinsCountLabel: UILabel!
    @IBOutlet var prizesCountLabel: UILabel!
    @IBOutlet var prizesStackView: UIStackView!
    @IBOutlet var votesCountLabel: UILabel!
    @IBOutlet var votesStackView: UIStackView!
    @IBOutlet var followersCountLabel: UILabel!
    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var followButton: UIButton!
    @IBOutlet var followingsStackView: UIStackView!
    @IBOutlet var followersStackView: UIStackView!
    @IBOutlet var tagsContainerView: UIView!

    weak var delegate: ProfileDetailsDelegate?

    var user: ProfileDetailsDisplayModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = FeedTableViewCell.cornerRadius
        containerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]

        followButton.addTarget(self, action: #selector(didTapFollow(_:)), for: .touchUpInside)
        [prizesStackView, votesStackView, followersStackView, followingsStackView].enumerated().forEach { index, view in
            view.isUserInteractionEnabled = true
            view.tag = index
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapCount(_:))))
        }

        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfile(_:))))

        bioLabel.numberOfLines = 3
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelAction(gesture:)))
        bioLabel.addGestureRecognizer(tap)
        bioLabel.isUserInteractionEnabled = true

        registerNotifications()
    }

    @objc
    private func didTapFollow(_ sender: UIButton) {
        guard let user else { return }
        if user.id == UserSettings.shared.id {
            delegate?.navigateToEdit()

        } else {
            if user.followingStatus == .unfollowing {
                delegate?.profileDetails(didFollowUser: user)

            } else {
                delegate?.profileDetails(didUnfollowUser: user)
            }
        }
    }

    @objc
    private func didTapCount(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag,
              let user else { return }
        switch tag {
        case 0:
            delegate?.profileDetails(willViewPrizes: user)
        case 1:
            delegate?.profileDetails(willViewVotes: user)
        case 2:
            delegate?.profileDetails(willViewFollowers: user)
        case 3:
            delegate?.profileDetails(willViewFollowings: user)
        default:
            break
        }
    }

    @objc
    private func didTapProfile(_ sender: UITapGestureRecognizer) {
        guard let user else { return }
        delegate?.profileDetails(willViewProfilePhoto: user)
    }

    @objc
    private func labelAction(gesture: UITapGestureRecognizer) {
        if bioLabel.numberOfLines == 0 {
            bioLabel.numberOfLines = 3
        } else {
            bioLabel.numberOfLines = 0
        }
    }

    func configure(_ model: DisplayModel) {
        guard let details = model as? ProfileDetailsDisplayModel else {
            // TODO: Add a placeholder?
            return
        }

        user = details

        profileImageView.loadImage(urlString: details.profileThumbnailURL)

        fullNameLabel.text = details.fullName
        usernameLabel.text = details.username
        bioLabel.text = details.bio
        coinsCountLabel.text = details.coinsCount
        prizesCountLabel.text = details.prizesCount
        votesCountLabel.text = details.votesCount
        followersCountLabel.text = details.followersCount
        followingCountLabel.text = details.followingCount

        if details.isMe {
            // My profile
            followButton.setBackgroundImage(UIImage(named: "Button-Edit"), for: .normal)

        } else {
            followButton.setBackgroundImage(details.followingStatus.buttonBackgroundImage, for: .normal)
        }

        // Tags
        let tagsContentView = UserTagsView(tags: details.tags)

        let config = UIHostingConfiguration {
            tagsContentView
        }
        let tagsView = config.makeContentView()

        tagsView.translatesAutoresizingMaskIntoConstraints = false

        tagsContainerView.addSubview(tagsView)

        NSLayoutConstraint.activate([
            tagsView.topAnchor.constraint(equalTo: tagsContainerView.topAnchor),
            tagsView.leadingAnchor.constraint(equalTo: tagsContainerView.leadingAnchor),
            tagsView.trailingAnchor.constraint(equalTo: tagsContainerView.trailingAnchor),
            tagsView.bottomAnchor.constraint(equalTo: tagsContainerView.bottomAnchor),
        ])
    }
}

private extension ProfileDetailsCollectionViewCell {
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadImage), name: .shouldReloadMeProfilePhoto, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadCoinsCount), name: .shouldReloadMeCoinsCount, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadPrizesCount), name: .shouldReloadMePrizesCount, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadFollowersCount), name: .shouldReloadMeFollowersCount, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadFollowingsCount), name: .shouldReloadMeFollowingsCount, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadInfo), name: .shouldReloadMeInfo, object: nil)
    }

    @objc
    func shouldReloadImage() {
        DispatchQueue.main.async {
            self.profileImageView.loadImage(urlString: UserSettings.shared.profilePhotoThumbnail, isReloading: true)
        }
    }

    @objc
    func shouldReloadCoinsCount() {
        DispatchQueue.main.async {
            self.coinsCountLabel.text = "\(UserSettings.shared.coinsCount)"
        }
    }

    @objc
    func shouldReloadPrizesCount() {
        DispatchQueue.main.async {
            self.prizesCountLabel.text = "\(UserSettings.shared.prizesCount)"
        }
    }

    @objc
    func shouldReloadFollowersCount() {
        DispatchQueue.main.async {
            self.followersCountLabel.text = "\(UserSettings.shared.followersCount)"
        }
    }

    @objc
    func shouldReloadFollowingsCount() {
        DispatchQueue.main.async {
            self.followingCountLabel.text = "\(UserSettings.shared.followingsCount)"
        }
    }

    @objc
    func shouldReloadInfo() {
        DispatchQueue.main.async {
            self.usernameLabel.text = UserSettings.shared.username
            self.fullNameLabel.text = UserSettings.shared.fullName
            self.bioLabel.text = UserSettings.shared.biography
        }
    }
}
