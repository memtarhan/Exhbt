//
//  InvitationController.swift
//  Exhbt
//
//  Created by Shouvik Paul on 6/8/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit

class InvitationController: UIViewController {
    
    enum InviteError {
        case generic
        case maxParticipants
        case alreadyJoined
        case alreadyLive
        case expired
    }
    
    lazy var competitionInteractor: CompetitionInteractor = {
        let interactor = CompetitionInteractor()
        interactor.delegate = self
        return interactor
    }()
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    let inviteLabel = Label(title: "You've been invited", fontSize: 54, weight: .bold)
    let categoryLabel = Label(title: "Category", fontSize: 14)
    let dividerView = UIView()
    let winLabel = Label(title: "win and earn", fontSize: 14)
    
    lazy var uploadButton: Button = {
        let button = PrimaryButton(title: "Upload your photo!")
        button.addAction(#selector(uploadTap), for: self)
        return button
    }()
    
    private var inviteError: InviteError?
    
    private var competitionID: String
    private var competition: CompetitionDataModel?
    
    init(competitionID: String) {
        self.competitionID = competitionID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        competitionInteractor.getCompetitionForInvite(by: competitionID)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let error = inviteError {
            presentError(error)
        }
        if competition == nil {
            presentLoadingScreen()
        }
    }
    
    private func setupView(for comp: CompetitionDataModel) {
        view.backgroundColor = .white
        
        setNavigationTitleView()
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeTap))
        navigationItem.rightBarButtonItem = closeButton
        
        setupImage(comp)
        setupUser(comp)
        setupInviteLabel()
        setupCategory(comp)
        setupWin()
        setupUploadButton()
    }
    
    private func setupImage(_ comp: CompetitionDataModel) {
        let imageView = CustomImageView(
            imageID: comp.challengeImages[0].imageID,
            sizes: ImageSize.smallest(.small)
        )
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        
        view.addSubview(blurView)
        blurView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(imageView)
            make.height.equalTo(32)
        }
    }
    
    private func setupUser(_ comp: CompetitionDataModel) {
        guard let user = comp.creator else { return }
        
        var imageView: UIImageView
        if let avatarImageID = user.avatarImageUrl, avatarImageID != "" {
            imageView = CustomImageView(
                imageID: avatarImageID,
                sizes: ImageSize.smallest(.tiny)
            )
        } else {
            imageView = Utilities.defaultUserImageView()
        }
        imageView.backgroundColor = .black
        imageView.layer.cornerRadius = 24
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(imageView.layer.cornerRadius * 2)
            make.left.equalToSuperview().inset(16)
            make.centerY.equalTo(blurView)
        }
        
        guard let name = user.name else { return }
        let challengeLabel = Label(title: name + " wants to challenge you!")
        view.addSubview(challengeLabel)
        challengeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageView.snp.right).offset(12)
            make.centerY.equalTo(blurView)
        }
    }
    
    private func setupInviteLabel() {
        inviteLabel.numberOfLines = 0
        view.addSubview(inviteLabel)
        inviteLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(blurView.snp.bottom).offset(32)
        }
    }

    private func setupUploadButton() {
        view.addSubview(uploadButton)
        uploadButton.snp.makeConstraints { (make) in
            let bottomInset = Utilities.hasNotch() ? 20 : 40
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(bottomInset)
            make.centerX.equalToSuperview()
            make.width.equalTo(Button.bigWidth)
            make.height.equalTo(Button.bigHeight)
        }
    }
    
    private func setupCategory(_ comp: CompetitionDataModel) {
        categoryLabel.textColor = .gray
        view.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(inviteLabel.snp.bottom).offset(32)
            make.left.equalToSuperview().inset(12)
        }
        
        let label = Label(title: comp.category, fontSize: 32, weight: .bold)
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(categoryLabel.snp.bottom).offset(2)
            make.left.equalTo(categoryLabel)
        }
        
        dividerView.backgroundColor = .gray
        view.addSubview(dividerView)
        dividerView.snp.makeConstraints { (make) in
            make.left.equalTo(label.snp.right).offset(32)
            make.top.equalTo(categoryLabel.snp.top).offset(-2)
            make.bottom.equalTo(label.snp.bottom).offset(2)
            make.width.equalTo(2)
        }
    }
    
    private func setupWin() {
        winLabel.textColor = .gray
        view.addSubview(winLabel)
        winLabel.snp.makeConstraints { (make) in
            make.top.equalTo(categoryLabel)
            make.left.equalTo(dividerView.snp.right).offset(32)
        }
        
        let label = Label(title: "+ \(AppConstants.CoinsForWin)", fontSize: 32, weight: .bold)
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(winLabel.snp.bottom).offset(2)
            make.left.equalTo(winLabel)
        }
    }
    
    @objc func closeTap() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func uploadTap() {
        guard let comp = competition else {
            presentError(.generic)
            return
        }
        let controller = CreateCompetitionController(data: comp, fromInvite: true)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func attempToPresentError(for error: InviteError) {
        if isVisible() {
            presentError(error)
        } else {
            inviteError = error
        }
    }

    private func presentError(_ error: InviteError) {
        var title: String = "Sorry"
        var message: String
        switch error {
        case .generic:
            title = "Error"
            message = "Sorry there is an error with this competition link"
        case .maxParticipants:
            message = "This compeition has already reached the maximum participants (\(AppConstants.competitionMaxParticipants))"
        case .alreadyJoined:
            message = "You have already submitted a photo to this competition"
        case .alreadyLive:
            message = "This competition is already live"
        case .expired:
            message = "This competition has already expired"
        }
        presentAlert(
            title: title,
            message: message,
            completion: { _ in
                self.dismiss(animated: true, completion: nil)
        })
    }
}

extension InvitationController: CompetitionInteractorDelegate {
    func receivedCompetition(_ competition: CompetitionDataModel) {
        removeLoadingScreen()
        print("comp: \(competition)")
        setupView(for: competition)

        self.competition = competition
        if competition.state == .live {
            attempToPresentError(for: .alreadyLive)
            return
        }
        if competition.state == .expired {
            attempToPresentError(for: .expired)
            return
        }
        if let userID = UserManager.shared.user?.userID {
            let userImages = competition.challengeImages.filter { return $0.userID == userID }
            if userImages.count > 0 {
                attempToPresentError(for: .alreadyJoined)
                return
            }
        }
        if competition.challengeImages.count >= 4 {
            attempToPresentError(for: .maxParticipants)
        }
    }
    
    func errorReceivingCompetition(_ error: Error) {
        removeLoadingScreen()
        print("error getting comp: \(error)")
        attempToPresentError(for: .generic)
    }
}
