//
//  FollowerListCell.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 03/05/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import UIKit

protocol FollowerListCellDelegate: AnyObject {
    func didTapFollow(user: FollowerDisplayModel)
    func didTapFollowing(user: FollowerDisplayModel)
}

class FollowerListCell: UITableViewCell {
    
    static let resuseIdentifier = "FollowerListCell"
    
    @IBOutlet var userImageView: CircleImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var followButton: UIButton!
    @IBOutlet var followingButton: UIButton!
    
    weak var delegate: FollowerListCellDelegate?
    var user: FollowerDisplayModel!
    
    func configureUser(with user: FollowerDisplayModel, on delegate: FollowerListCellDelegate) {
        self.delegate = delegate
        self.user = user
        userNameLabel?.text = user.username
        if let url = URL(string: user.profilePhoto ?? "") {
            userImageView?.kf.setImage(with: url)
        }
        if UserSettings.shared.id == user.id {
            followButton.isHidden = true
            followingButton.isHidden = true
        } else {
            let followingStatus = user.followingStatus
            followButton.isHidden = followingStatus == .following
            followingButton.isHidden = followingStatus == .unfollowing
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func didTapFollow() {
        delegate?.didTapFollow(user: user)
    }
    
    @IBAction func didTapFollowing() {
        delegate?.didTapFollowing(user: user)
    }
}

class FollowerListTableViewDiffableDataSource: UITableViewDiffableDataSource<FollowersSection, FollowerDisplayModel> {}
