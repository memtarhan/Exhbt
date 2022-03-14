//
//  ExternalInviteViewController.swift
//  Exhbt
//
//  Created by Shouvik Paul on 9/8/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class ExternalInviteViewController: ModalViewController {
    
    let competitionID: String
    
    let titleLabel = Label(
        title: "Looks like you’re\nthe first one here.",
        fontSize: 24,
        weight: .bold)
    
    let subtitleLabel = Label(
    title: "Show off your photography chops\n and invite your friends to Exhbt.",
    fontSize: 16)
    
    let inviteButton = PrimaryButton(title: "Invite friends")
    
    init(competitionID: String) {
        self.competitionID = competitionID
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        setupTitle()
        setupSubtitle()
        setupInviteButton()
    }
    
    private func setupTitle() {
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        modalView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(64)
            make.left.right.equalToSuperview().inset(12)
            make.width.equalTo(310)
        }
    }
    
    private func setupSubtitle() {
        subtitleLabel.numberOfLines = 2
        subtitleLabel.textAlignment = .center
        modalView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(34)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupInviteButton() {
        inviteButton.layer.cornerRadius = 22
        inviteButton.addAction(#selector(inviteTap), for: self)
        modalView.addSubview(inviteButton)
        inviteButton.snp.makeConstraints { (make) in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(44)
            make.bottom.equalToSuperview().inset(40)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalToSuperview().dividedBy(2)
        }
    }
    
    @objc func inviteTap() {
        presentInviteActivity(competitionID: competitionID)
    }
}
