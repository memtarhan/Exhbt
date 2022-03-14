//
//  NewsfeedVoteController.swift
//  Exhbt
//
//  Created by Steven Worrall on 6/11/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import MessageUI

protocol NewsfeedVoteControllerDelegate: AnyObject {
    func didVote(comp: CompetitionDataModel?)
}

class NewsfeedVoteController: UIViewController {
    weak var delegate: NewsfeedVoteControllerDelegate?

    var data: CompetitionDataModel? = nil
    let newsfeedInteractor = NewsfeedInteractor()
    
    private let collectionCellID = "myCellID"
    
    private let collectionView: UICollectionView = {
        let tempLayout = UICollectionViewFlowLayout()
        tempLayout.scrollDirection = .horizontal
        tempLayout.minimumInteritemSpacing = 0
        tempLayout.minimumLineSpacing = 0
        let tempCollection = UICollectionView(frame: .zero, collectionViewLayout: tempLayout)
        tempCollection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tempCollection.showsHorizontalScrollIndicator = false
        tempCollection.backgroundColor = .black
        tempCollection.isPagingEnabled = true
        return tempCollection
    }()
    
    private let bottomView = UIView()
    private let bottomStack: UIStackView = {
        let temp = UIStackView()
        temp.distribution = .fillProportionally
        temp.alignment = .leading
        temp.axis = .horizontal
        temp.spacing = 8.0
        temp.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        temp.backgroundColor = .black
        return temp
    }()
    private let voteButton = UIButton()
    private let votesLabel: Label = {
        let temp = Label(title: "", fontSize: 20, weight: .regular)
        temp.textColor = .white
        return temp
    }()
    
    private let emptyState = CompetitionEmptyState()
    
    private var errorToPresent = false
    
    var isLiveCompFromNewsFeed: Bool {
        return fromNewsFeed && data?.state == .live
    }
    var userVotedBefore: Bool = false
    var canUserVote: Bool {
        return isLiveCompFromNewsFeed && !userVotedBefore
    }
    
    var fromNewsFeed: Bool = true
    
    var currentImageIndex: Int = -1
    var votedImages: Set<String> = []
    
    init(competitionID: String, fromNewsFeed: Bool) {
        self.fromNewsFeed = fromNewsFeed
        super.init(nibName: nil, bundle: nil)

        newsfeedInteractor.delegate = self
        newsfeedInteractor.getCompetition(by: competitionID)
    }
    
    init(competition: CompetitionDataModel) {
        self.data = competition
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        if let data = data {
            changeDataInView(comp: data)
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "MoreIcon"), style: .plain, target: self, action: #selector(self.moreButtonSelected))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if errorToPresent {
            presentError()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // update competition with votes if
        //  user is going back to feed,
        //  and if user has voted on some images
        if isMovingFromParent,
           votedImages.count > 0,
           let comp = self.data {
            newsfeedInteractor.updateCompetitionWithVotes(
                comp: comp,
                votedImages: votedImages
            )
            
            self.data?.updateWithVote(images: self.votedImages)
            
            self.delegate?.didVote(comp: self.data)
        }
    }
    
    public func changeDataInView(comp: CompetitionDataModel) {
        print("showing competition \(comp.competitionID)")
        
        self.emptyState.isHidden = true
        currentImageIndex = -1
        
        self.data = comp
        userVotedBefore = false
        if let currUserID = UserManager.shared.user?.userID {
            for image in comp.challengeImages {
                for userID in image.voters {
                    if userID == currUserID {
                        userVotedBefore = true
                        break
                    }
                }
            }
        }
        
        self.setupCollectionView()
        self.setupBottomView()
        self.addStackImages()
        self.setupVoteButton()
        self.setStateForIndex(index: 0)
        reloadViews()
    }
    
    public func showEmptyState() {
        self.emptyState.isHidden = false
        
        self.data = nil
        self.reloadViews()
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.emptyState)
        self.emptyState.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupBottomView() {
        self.bottomView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        self.view.addSubview(self.bottomView)
        self.bottomView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(160)
        }
        
        self.bottomView.addSubview(self.bottomStack)
        self.bottomStack.snp.makeConstraints { make in
            make.bottom.centerX.equalToSuperview()
            make.trailing.lessThanOrEqualTo(self.bottomView.snp.trailing).priority(999)
            make.leading.lessThanOrEqualTo(self.bottomView.snp.leading).priority(999)
            make.height.equalTo(80)
        }
    }

    private func addStackImages() {
        if let data = self.data {
            for image in data.challengeImages {
                let imageView = CustomImageView(imageID: image.imageID, sizes: [.small])
                imageView.contentMode = .scaleAspectFill
                imageView.backgroundColor = .clear
                imageView.layer.cornerRadius = 4
                imageView.layer.masksToBounds = true
                
                imageView.snp.makeConstraints { make in
                    make.width.equalTo(50)
                }
                
                self.bottomStack.addArrangedSubview(imageView)
            }
        }
    }
    
    private func setupVoteButton() {
        voteButton.isUserInteractionEnabled = canUserVote
        
        voteButton.addAction(#selector(voteTapped), for: self)
        self.voteButton.layer.cornerRadius = 25
        self.voteButton.layer.masksToBounds = true
        self.bottomView.addSubview(self.voteButton)
        self.voteButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12)
        }
        
        self.bottomView.addSubview(self.votesLabel)
        self.votesLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.voteButton.snp.centerY)
            make.leading.equalToSuperview().inset(12)
        }

        self.voteButton.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -10.0, bottom: 0.0, right: 0.0)
        self.voteButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 15.0)
    }
    
    private func setStateForIndex(index: Int) {
        self.currentImageIndex = index
        for i in 0...self.bottomStack.arrangedSubviews.count - 1 {
            if i == index {
                self.bottomStack.arrangedSubviews[i].alpha = 1.0
            } else {
                self.bottomStack.arrangedSubviews[i].alpha = 0.4
            }
        }
        
        var voted = false
        if let userID = UserManager.shared.user?.userID {
            voted = data?.challengeImages[index].voters.contains(userID) ?? false
        }
        self.setVoteButtonState(voted: voted)
        self.votesLabel.text = "👍 \(self.data?.challengeImages[index].voters.count ?? 0)"
    }
    
    private func setVoteButtonState(voted: Bool) {
        if voted {
            self.voteButton.setTitle("👍", for: .normal)
            self.voteButton.backgroundColor = UIColor.init(named: "ExhbtGrey")
            self.voteButton.setImage(nil, for: .normal)
            voteButton.isHidden = false
        } else {
            self.voteButton.setTitle("Vote", for: .normal)
            self.voteButton.backgroundColor = .systemBlue
            self.voteButton.setImage(UIImage(named: "VoteThumb"), for: .normal)
            if !canUserVote {
                // don't show vote button if user did not vote for picture,
                // but if user is can not vote
                voteButton.isHidden = true
            }
        }
    }
    
    private func reloadViews() {
        self.collectionView.reloadData()
    }
    
    @objc func moreButtonSelected() {
        self.presentActionSheet()
    }
    
    @objc func voteTapped() {
        guard voteButton.isUserInteractionEnabled,
              currentImageIndex >= 0,
              let imageID = data?.challengeImages[currentImageIndex].imageID else {
            return
        }
        voteButton.isUserInteractionEnabled = false
    
        let prevVoted = votedImages.contains(imageID)
        setVoteButtonState(voted: !prevVoted)
        if prevVoted {
            // previous state was voted, so remove vote
            votedImages.remove(imageID)
        } else {
            // previous stat was not voted, add vote
            votedImages.insert(imageID)
        }
        
        voteButton.isUserInteractionEnabled = true
    }
    
    private func presentActionSheet() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheetController.modalPresentationStyle = .popover
        if let presentation = actionSheetController.popoverPresentationController {
            presentation.barButtonItem = navigationItem.rightBarButtonItem
        }

        let report = UIAlertAction(
            title: "Report",
            style: .destructive
        ) { [weak self] _ in
            guard let self = self else { return }
            
            self.createReportEmail(competitionID: self.data?.competitionID ?? "")
        }
        actionSheetController.addAction(report)

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheetController.addAction(cancelAction)

        actionSheetController.popoverPresentationController?.sourceView = view
        present(actionSheetController, animated: true)
    }
}

extension NewsfeedVoteController: NewsfeedInteractorDelegate {
    func didReceiveCompetition(_ competition: CompetitionDataModel) {
        self.data = competition
        changeDataInView(comp: competition)
    }

    func errorReceivingCompetition(_ error: CompetitionError) {
        if isVisible() {
            presentError()
        } else {
            self.errorToPresent = true
        }
    }
    
    func presentError() {
        presentAlert(
            title: "Error",
            message: "Sorry, there was an problem loading the competition. Please try again later"
        )
    }
}

extension NewsfeedVoteController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(NewsfeedVoteCell.self, forCellWithReuseIdentifier: self.collectionCellID)
        
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataCount = self.data?.challengeImages.count else { return 0 }
        
        return dataCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.collectionCellID, for: indexPath) as! NewsfeedVoteCell
            
        let image = self.data?.challengeImages[indexPath.row]
        cell.set(image: image)
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.bounds.width, height: self.collectionView.bounds.height)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        voteButton.isUserInteractionEnabled = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in self.collectionView.visibleCells {
            let indexPath = self.collectionView.indexPath(for: cell)
            
            print("indexpath: \(String(describing: indexPath))")
            self.setStateForIndex(index: indexPath?.row ?? 0)
        }
    }
}

extension NewsfeedVoteController: MFMailComposeViewControllerDelegate {
    func createReportEmail(competitionID: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["exhbtmain@gmail.com"])
            mail.setSubject("Reporting Competiton \(competitionID)")
            mail.setMessageBody("Please describe why you're reporting this competition.\n\n\n\nDo not edit below this.\nCompetiton ID: \(competitionID)", isHTML: false)

            self.present(mail, animated: true)
        } else {
            self.presentAlert(title: "Error reporting competition.", message: "Please try again soon.")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
