//
//  TopProfileCell.swift
//  Exhbt
//
//  Created by Steven Worrall on 6/4/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import SnapKit

protocol TopProfileCellDelegate: AnyObject {
    func editProfileTapped()
    func followButtonTapped()
    func challengeButtonTapped()
    func followersTapped()
}

class TopProfileCell: UITableViewCell {
    var delegate: TopProfileCellDelegate?
    let userManager = UserManager.shared
    
    public static var imageHeight = UIScreen.main.bounds.width * 0.56
    private lazy var buttonWidth = UIScreen.main.bounds.width * 0.43
    private lazy var buttonHeight = self.buttonWidth * 0.24
    
    private lazy var imageSize = UIScreen.main.bounds.width * 0.35
    
    private lazy var isCurrentUser: Bool = false
    private lazy var isAllowedAccess: Bool = false
    private lazy var isFollowing: Bool = false
    private lazy var hasRequested: Bool = false
    
    private lazy var customImageView: CustomImageView = {
        let temp = CustomImageView(sizes: ImageSize.smallest(.small))
        temp.backgroundColor = .black
        temp.isUserInteractionEnabled = true
        temp.layer.masksToBounds = true
        temp.layer.cornerRadius = self.imageSize / 2
        return temp
    }()
    private lazy var editProfileButton: UIButton = {
        let temp = ProfileButton(title: "Edit Profile", fontSize: 18)
        temp.layer.cornerRadius = self.buttonHeight / 2
        return temp
    }()
    private lazy var followButton: UIButton = {
        let temp = ProfileButton(title: "Follow", fontSize: 18)
        temp.layer.cornerRadius = self.buttonHeight / 2
        return temp
    }()
    private lazy var challengeButton: UIButton = {
        let temp = ProfileButton(title: "Challenge", fontSize: 18)
        temp.layer.cornerRadius = self.buttonHeight / 2
        return temp
    }()
    private let noProfilePictureButton: UIButton = {
        let temp = Button(title: "Add a Profile Picture", fontSize: 18)
        temp.setTitleColor(.white, for: .normal)
        return temp
    }()
    private let nameLabel = CenteredLabel(title: "Name", fontSize: 22, weight: .bold)
    private let descriptionLabel = CenteredLabel(title: "Description", fontSize: 16, weight: .regular)
    private let winsLabel = CenteredLabel(title: "Wins", fontSize: 16, weight: .semiBold)
    private let winsDataLabel = CenteredLabel(title: "0", fontSize: 20, weight: .bold)
    private let followersLabel = CenteredLabel(title: "Followers", fontSize: 16, weight: .semiBold)
    private let followersDataLabel = CenteredLabel(title: "0", fontSize: 20, weight: .bold)
    private let galleryLabel = CenteredLabel(title: "Gallery", fontSize: 16, weight: .regular)
    
    private let partitionLine: UIView = {
        let temp = UIView()
        temp.backgroundColor = .LighterGray()
        return temp
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(
        _ user: User,
        followers: Int,
        isAllowedAccess: Bool,
        isFollowing: Bool,
        hasRequested: Bool,
        blocked: Bool
    ) {
        self.isCurrentUser = UserManager.shared.user?.userID == user.userID
        self.isAllowedAccess = isAllowedAccess
        self.isFollowing = isFollowing
        self.hasRequested = hasRequested
        
        self.setTextLabels(user, followers: followers)
        self.setFollowButtonText()
        self.setupImageView(user)
        
        self.setupViews()
        self.addSelectors()
        
        followButton.isHidden = blocked
        challengeButton.isHidden = blocked
    }
    
    private func addSelectors() {
        self.editProfileButton.addTarget(self, action: #selector(self.editProfileButtonPressed), for: UIControl.Event.touchUpInside)
        self.noProfilePictureButton.addTarget(self, action: #selector(self.editProfileButtonPressed), for: UIControl.Event.touchUpInside)
        self.followButton.addTarget(self, action: #selector(self.followButtonPressed), for: UIControl.Event.touchUpInside)
        self.challengeButton.addTarget(self, action: #selector(self.challengeButtonPressed), for: UIControl.Event.touchUpInside)
        
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(self.followersPressed))
        self.followersLabel.isUserInteractionEnabled = true
        self.followersLabel.addGestureRecognizer(followersTap)
        
        let followersDataTap = UITapGestureRecognizer(target: self, action: #selector(self.followersPressed))
        self.followersDataLabel.isUserInteractionEnabled = true
        self.followersDataLabel.addGestureRecognizer(followersDataTap)
    }
    
    private func setupImageView(_ user: User) {
        self.customImageView.setImage(with: user.avatarImageUrl ?? "")
//        guard let imageID = user.avatarImageUrl else { return }
            
        self.noProfilePictureButton.isHidden = true
    }
    
    private func setTextLabels(_ user: User, followers: Int) {
        nameLabel.text = user.name
        descriptionLabel.text = user.bio ?? "User has no bio."
        winsDataLabel.text = String(user.wins)
        followersDataLabel.text = String(followers)
    }
    
    private func setFollowButtonText() {
        if self.isFollowing {
            self.followButton.setTitle("Following", for: .normal)
            self.followButton.backgroundColor = .white
            self.followButton.setTitleColor(UIColor.EXRed(), for: .normal)
        } else {
            self.followButton.setTitle("Follow", for: .normal)
            self.followButton.backgroundColor = UIColor.EXRed()
            self.followButton.setTitleColor(.white, for: .normal)
        }
        
        if self.hasRequested {
            self.followButton.setTitle("Requested", for: .normal)
            self.followButton.backgroundColor = .white
            self.followButton.setTitleColor(UIColor.EXRed(), for: .normal)
        }
    }
    
    public func setWinsLabel(wins: String) {
        winsDataLabel.text = wins
    }
    
    public func setFollowersLabel(followers: String) {
        followersDataLabel.text = followers
    }
    
//    private func setupViews() {
//        self.setupTopViews()
//        self.setupDataViews()
//        self.setupBottomViews()
//        self.addEditButton()
//        self.addFollowButton()
//        self.addChallengeButton()
//
//    }
//
//    private func setViewsHidden() {
//
//    }
    
    private func setupViews() {
        self.setupTopViews()

        if self.isAllowedAccess {
            self.setupDataViews()
            self.setupBottomViews()

            if self.isCurrentUser {
                self.addEditButton()
            } else {
                self.addFollowButton()
                self.addChallengeButton()
            }
        } else {
            self.addFollowButton()
        }
    }
    
    private func setupTopViews() {
        self.contentView.addSubview(self.customImageView)
        self.customImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(self.imageSize)
            make.top.equalToSuperview().inset(20)
            make.centerX.equalTo(self.contentView.snp.centerX)
        }
        
        self.customImageView.addSubview(self.noProfilePictureButton)
        self.noProfilePictureButton.snp.makeConstraints { (make) in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        
        self.contentView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.customImageView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        self.contentView.addSubview(self.descriptionLabel)
        self.descriptionLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(10)
        }
    }
    
    private func setupDataViews() {
        self.contentView.addSubview(self.winsLabel)
        self.winsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.descriptionLabel.snp.bottom).offset(20)
            make.centerX.equalTo(self.snp.centerX).offset(-60)
        }

        self.contentView.addSubview(self.followersLabel)
        self.followersLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.descriptionLabel.snp.bottom).offset(20)
            make.centerX.equalTo(self.snp.centerX).offset(60)
        }
        
        self.contentView.addSubview(self.winsDataLabel)
        self.winsDataLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.winsLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self.winsLabel.snp.centerX)
        }

        self.contentView.addSubview(self.followersDataLabel)
        self.followersDataLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.followersLabel.snp.bottom).offset(5)
            make.centerX.equalTo(self.followersLabel.snp.centerX)
        }
    }
    
    private func setupBottomViews() {
        self.contentView.addSubview(self.galleryLabel)
        self.galleryLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(5)
            make.leading.trailing.equalToSuperview()
        }
        
        self.contentView.addSubview(self.partitionLine)
        self.partitionLine.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.galleryLabel.snp.top).offset(-20)
        }
    }
    
    private func addEditButton() {
        self.contentView.addSubview(self.editProfileButton)
        self.editProfileButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.followersDataLabel.snp.bottom).offset(20)
            make.width.equalTo(self.buttonWidth)
            make.height.equalTo(self.buttonHeight)
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.bottom.equalTo(self.partitionLine.snp.top).offset(-20)
        }
    }
    
    private func addFollowButton() {
        self.contentView.addSubview(self.followButton)
        self.followButton.snp.makeConstraints { (make) in
            make.width.equalTo(self.buttonWidth)
            make.height.equalTo(self.buttonHeight)
        }
        
        if self.isAllowedAccess {
            self.followButton.snp.makeConstraints { (make) in
                make.top.equalTo(self.followersDataLabel.snp.bottom).offset(20)
                make.trailing.equalTo(self.contentView.snp.centerX).offset(-10)
                make.bottom.equalTo(self.partitionLine.snp.top).offset(-20)
            }
        } else {
            self.followButton.snp.makeConstraints { (make) in
                make.top.equalTo(self.descriptionLabel.snp.bottom).offset(20)
                make.centerX.equalTo(self.contentView.snp.centerX)
                make.bottom.equalToSuperview().offset(-20)
            }
        }
        
    }
    
    private func addChallengeButton() {
        self.contentView.addSubview(self.challengeButton)
        self.challengeButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.followersDataLabel.snp.bottom).offset(20)
            make.width.equalTo(self.buttonWidth)
            make.height.equalTo(self.buttonHeight)
            make.leading.equalTo(self.contentView.snp.centerX).offset(10)
            make.bottom.equalTo(self.partitionLine.snp.top).offset(-20)
        }
    }
    
    @objc func editProfileButtonPressed(sender: UIButton!) {
        self.delegate?.editProfileTapped()
    }
    
    @objc func followButtonPressed(sender: UIButton!) {
        if self.followButton.currentTitle != "Requested" {
            self.delegate?.followButtonTapped()
        } else {
            print("User has requested already. No action needed")
        }
    }
    
    @objc func challengeButtonPressed(sender: UIButton!) {
        self.delegate?.challengeButtonTapped()
    }
    
    @objc func followersPressed(sender: UIButton!) {
        self.delegate?.followersTapped()
    }

}
