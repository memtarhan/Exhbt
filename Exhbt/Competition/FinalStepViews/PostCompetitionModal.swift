//
//  PostCompetitionModal.swift
//  Exhbt
//
//  Created by Shouvik Paul on 9/8/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import Lottie

class PostCompetitionModal: ModalViewController {
    
    let titleLabel = Label(
        title: "You’ve started\na new contest!",
        fontSize: 24,
        weight: .bold)
    
    let subtitleLabel = Label(
        title:
        """
        Thanks for inviting some
        friends to join Exhbt!


        They’ve got 24 hours to sign
        up and select a photo to start
        the challenge.
        """,
        fontSize: 16)
    
    let goodLuckLabel = Label(
        title: "Good Luck!",
        fontSize: 16,
        weight: .boldItalic)
    
    let inviteButton = PrimaryButton(title: "Invite friends to the app")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.playAnimation()
        }
    }
    
    private func playAnimation() {
        let animationView = AnimationView(name: "MinusFiveCoins")
        view.addSubview(animationView)
        animationView.snp.makeConstraints { (make) in
            make.width.height.equalToSuperview().multipliedBy(2)
            make.center.equalToSuperview()
        }
        
        animationView.play(completion: { finished in
            animationView.removeFromSuperview()
        })
    }
    
    private func setupView() {
        setupTitle()
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
    
    private func setupSubtitle() {
        subtitleLabel.numberOfLines = 0
        modalView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(34)
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
        inviteButton.addAction(#selector(inviteTap), for: self)
        modalView.addSubview(inviteButton)
        inviteButton.snp.makeConstraints { (make) in
            make.top.equalTo(goodLuckLabel.snp.bottom).offset(80)
            make.bottom.equalToSuperview().offset(-40)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
    }
    
    @objc func inviteTap() {
        guard let inviteUrl = DeepLinkBuilder.createAppLink() else {
            presentAlert(
                title: "Error",
                message: "Could not create invite link. Please try again."
            )
            return
        }
        
        let text = "Join me on Exhbt now!"
        let sharedObjects = [inviteUrl as AnyObject, text as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.excludedActivityTypes = [.postToFacebook, .postToTwitter]
        
        present(activityViewController, animated: true, completion: nil)
    }
}
