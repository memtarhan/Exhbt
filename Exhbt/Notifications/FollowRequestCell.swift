//
//  FollowRequestCell.swift
//  Exhbt
//
//  Created by Shouvik Paul on 11/3/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

protocol FollowRequestCellDelegate: AnyObject {
    func deleteFollowRequest(from userID: String)
    func acceptFollowRequest(from userID: String)
}

class FollowRequestCell: NotificationCell {
    let confirmButton = PrimaryButton(title: "Confirm", fontSize: 12)
    let cancelButton = Button(title: "Cancel", fontSize: 12)
    
    var user: User?
    weak var delegate: FollowRequestCellDelegate?
    
    func set(user: User) {
        self.user = user
        if let name = user.name {
            nameLabel.text = name
        }
        avatarImageView.setImage(with: user.avatarImageUrl ?? "")
    }
    
    override func setupView() {
        super.setupView()
        
        setupConfirmButton()
        setupCancelButton()
    }
    
    private func setupConfirmButton() {
        confirmButton.addAction(#selector(acceptFollowRequest), for: self)
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.bottom.equalTo(avatarImageView)
            make.width.equalTo(100)
            make.height.equalTo(28)
        }
    }
    
    private func setupCancelButton() {
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.EXRed().cgColor
        cancelButton.setTitleColor(.EXRed(), for: .normal)
        cancelButton.addAction(#selector(deleteFollowRequest), for: self)
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalTo(confirmButton.snp.right).offset(16)
            make.top.equalTo(confirmButton)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
    }
    
    @objc func acceptFollowRequest() {
        guard let userID = user?.userID else { return }
        delegate?.acceptFollowRequest(from: userID)
    }
    
    @objc func deleteFollowRequest() {
        guard let userID = user?.userID else { return }
        delegate?.deleteFollowRequest(from: userID)
    }
}
