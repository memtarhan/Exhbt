//
//  DailyCoinModal.swift
//  Exhbt
//
//  Created by Steven Worrall on 10/26/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class DailyCoinModal: ModalViewController {
    lazy var userInteractor = ProfileInteractor()
    let userManager = UserManager.shared
    
    var user: User
    
    let titleLabel = Label(
        title: "You've got some \nmore coins!",
        fontSize: 24,
        weight: .bold)
    
    let coinLabel = Label(title: "100 Coins", fontSize: 46, weight: .bold)
    
    let subtitleLabel = Label(
        title:
        """
        Wager your coins by creating
        challenges.

        You can gain more coins by
        winning challenges, voting,
        or inviting friends to the app!
        """,
        fontSize: 16)
    
    let goodLuckLabel = Label(
        title: "Good Luck!",
        fontSize: 16,
        weight: .boldItalic)
    
    let inviteButton = PrimaryButton(title: "Close")
    
    init(user: User) {
        self.user = user
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        self.updateUser()
    }
    
    private func setupView() {
        setupTitle()
        setupCoinLabel()
        setupSubtitle()
        setupGoodLuckLabel()
        setupInviteButton()
        
        modalView.snp.remakeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupTitle() {
        titleLabel.numberOfLines = 2
        modalView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(64)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupCoinLabel() {
        coinLabel.numberOfLines = 0
        coinLabel.textColor = UIColor.EXRed()
        modalView.addSubview(coinLabel)
        coinLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(34)
            make.left.equalTo(titleLabel)
        }
    }
    
    private func setupSubtitle() {
        subtitleLabel.numberOfLines = 0
        modalView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(coinLabel.snp.bottom).offset(34)
            make.left.equalTo(titleLabel)
        }
    }
    
    private func setupGoodLuckLabel() {
        modalView.addSubview(goodLuckLabel)
        goodLuckLabel.snp.makeConstraints { (make) in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(36)
            make.left.equalTo(titleLabel)
        }
    }
    
    private func setupInviteButton() {
        inviteButton.addAction(#selector(closeTap), for: self)
        modalView.addSubview(inviteButton)
        inviteButton.snp.makeConstraints { (make) in
            make.top.equalTo(goodLuckLabel.snp.bottom).offset(80)
            make.bottom.equalToSuperview().offset(-40)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
    }
    
    private func updateUser(){
        self.user.coins += 100
        self.user.lastDailyCoins = Utilities.getCurrentDateString()
        userInteractor.updateUser(self.user)
    }
}
