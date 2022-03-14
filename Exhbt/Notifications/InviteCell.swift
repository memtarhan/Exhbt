//
//  InviteCell.swift
//  Exhbt
//
//  Created by Shouvik Paul on 11/3/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

protocol CompetitionInviteCellDelegate: AnyObject {
    func goToInvite(from notification: Notification)
    func deleteCompetitionInvite(notification: Notification)
}

class CompetitionInviteCell: NotificationCell {
    let startButton = PrimaryButton(title: "Start", fontSize: 12)
    let cancelButton = Button(title: "Cancel", fontSize: 12)
    
    var notif: Notification?
    weak var delegate: CompetitionInviteCellDelegate?
    
    func set(notif: Notification) {
        self.notif = notif
        if let name = notif.creator?.name {
            nameLabel.text = name
        }
        avatarImageView.setImage(with: notif.creator?.avatarImageUrl ?? "")
    }
    
    override func setupView() {
        super.setupView()
        
        setupStartButton()
        setupCancelButton()
    }
    
    private func setupStartButton() {
        startButton.addAction(#selector(startButtonTap), for: self)
        contentView.addSubview(startButton)
        startButton.snp.makeConstraints { (make) in
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
        cancelButton.addAction(#selector(cancelButtonTap), for: self)
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalTo(startButton.snp.right).offset(16)
            make.top.equalTo(startButton)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
    }
    
    @objc func startButtonTap() {
        if let notif = notif {
            delegate?.goToInvite(from: notif)
        }
    }
    
    @objc func cancelButtonTap() {
        if let notif = notif {
            delegate?.deleteCompetitionInvite(notification: notif)
        }
    }
}
