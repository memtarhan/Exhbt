//
//  ProfileController.swift
//  Exhbt
//
//  Created by Steven Worrall on 4/8/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import UIKit
import FirebaseDynamicLinks
import MessageUI

class ProfileController: UIViewController {
    private let topCellID = "topCellID"
    private let privateCellID = "privateCellID"
    private let galeryCellID = "galeryCellID"
    private let userManager = UserManager.shared
    private let profileInteractor = ProfileInteractor()
    
    private var isAllowedAccess: Bool = false
    private var isFollowing: Bool = false
    private var hasRequested: Bool = false
    private var canEdit: Bool {
        return user.userID == userManager.user?.userID
    }
    private var blocked = false
    
    private var followers: Int = 0
    
    private lazy var tableView: UITableView = {
        let temp = UITableView(frame: .zero, style: UITableView.Style.plain)
        temp.backgroundColor = .clear
        temp.separatorStyle = .none
        temp.tableFooterView = UIView()
        temp.rowHeight = UITableView.automaticDimension
        temp.estimatedRowHeight = UITableView.automaticDimension
        temp.addSubview(self.refreshControl)
        self.refreshControl.addTarget(self, action: #selector(self.reloadUserData(_:)), for: .valueChanged)
        return temp
    }()
    
    private let refreshControl = UIRefreshControl()
    
    private lazy var galleryController: GalleryViewController = {
        let temp = GalleryViewController(user: self.user)
        temp.cellPadding = 0
        temp.collectionViewPadding = 0
        temp.collectonView.isScrollEnabled = false
        return temp
    }()
    
    private var user: User
    
    init(user: User) {
        self.user = user
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileInteractor.delegate = self
        
        self.profileInteractor.getUser(by: user)
        self.profileInteractor.findFollowRequest(followUserID: self.user.userID)
        self.profileInteractor.getFollowers(for: self.user.userID)
        
        self.determineAccess()

        self.setupView()
        self.setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if canEdit, let user = userManager.user {
            self.user = user
        }
        self.reloadUserData(self)
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
        
        self.setNavigationTitleView()
        
        let barButton: UIBarButtonItem
        if user.userID == userManager.user?.userID {
            barButton = UIBarButtonItem(image: UIImage(named: "SettingsIcon"), style: .plain, target: self, action: #selector(settingsTap))
        } else {
            barButton = UIBarButtonItem(image: UIImage(named: "MoreIcon"), style: .plain, target: self, action: #selector(moreTap))
        }
        
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    private func determineAccess() {
        if self.user.userID == userManager.user?.userID {
            self.isAllowedAccess = true
            return
        }
        
        for followUser in userManager.following {
            if followUser.userID == self.user.userID {
                self.isAllowedAccess = true
                self.isFollowing = true
                return
            }
        }
        
        if !self.user.privateProfile {
            self.isAllowedAccess = true
        }
        
        blocked = userManager.blockedUsers.contains { return $0.blockedID == user.userID }
    }
    
    @objc func reloadUserData(_ send: Any) {
        self.refreshControl.beginRefreshing()
        
        if self.user.userID == userManager.user?.userID {
            if userManager.userUpdated, let updatedUser = userManager.user,
                user.userID == updatedUser.userID {
                self.user = updatedUser
                userManager.userUpdated = false
                tableView.reloadData()
            }
            self.refreshControl.endRefreshing()
        } else {
            self.profileInteractor.updateUser(self.user)
        }
    }
    
    @objc func settingsTap() {
        navigationController?.pushViewController(SettingsController(user: self.user), animated: true)
    }
    
    @objc func moreTap() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheetController.modalPresentationStyle = .popover
        if let presentation = actionSheetController.popoverPresentationController {
            presentation.barButtonItem = navigationItem.rightBarButtonItem
        }

        let blocked = userManager.blockedUsers.contains { $0.blockedID == user.userID }
        let block = UIAlertAction(
            title: (blocked) ? "Unblock" : "Block",
            style: .destructive
        ) { [weak self] _ in
            guard let self = self else { return }
            
            if blocked {
                print("presenting unblock alert")
                self.presentUnblockAlert()
            } else {
                print("presenting block alert")
                self.presentBlockAlert()
            }
        }
        
        actionSheetController.addAction(block)
        
        let report = UIAlertAction(
            title: "Report",
            style: .destructive
        ) { [weak self] _ in
            guard let self = self else { return }
            
            self.createReportEmail()
        }
        actionSheetController.addAction(report)

        let followsMe = userManager.followers.contains { $0.userID == user.userID }
        if followsMe {
            let removeFollowAction = UIAlertAction(
                title: "Remove Follower",
                style: .default
            ) { [weak self] _ in
                guard let self = self else { return }
                
                self.profileInteractor.removeFollower(followerID: self.user.userID)
                print("Remove Follower tapped")
            }
            actionSheetController.addAction(removeFollowAction)
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheetController.addAction(cancelAction)

        actionSheetController.popoverPresentationController?.sourceView = view
        present(actionSheetController, animated: true)
    }
    
    private func presentBlockAlert() {
        let name = user.name ?? "Account"
        let alert = UIAlertController(
            title: "Block \(name)",
            message: "The user will not be able to find or interact with your profile. The user will not be notified.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Block", style: .destructive, handler: {
            [weak self] _ in
            guard let self = self else { return }
            
            self.profileInteractor.block(blockedID: self.user.userID)
            self.blocked = true
            self.reloadUserData(self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func presentUnblockAlert() {
        let name = user.name ?? "Account"
        let alert = UIAlertController(
            title: "Unblock \(name)",
            message: "The user will now be able to find and interact with your profile. The user will not be notified.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Unblock", style: .destructive, handler: {
            [weak self] _ in
            guard let self = self else { return }
            
            self.profileInteractor.unblock(blockedID: self.user.userID)
            self.blocked = false
            self.reloadUserData(self)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}


extension ProfileController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(TopProfileCell.self, forCellReuseIdentifier: self.topCellID)
        self.tableView.register(GalleryProfileCell.self, forCellReuseIdentifier: self.galeryCellID)
        self.tableView.register(PrivateProfileCell.self, forCellReuseIdentifier: self.privateCellID)

        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.topCellID) as! TopProfileCell
            
            cell.set(
                user,
                followers: self.followers,
                isAllowedAccess: self.isAllowedAccess,
                isFollowing: self.isFollowing,
                hasRequested: self.hasRequested,
                blocked: blocked)
            cell.delegate = self
            cell.selectionStyle = .none
            
            return cell
        }
        
        if self.isAllowedAccess {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.galeryCellID) as! GalleryProfileCell
            
            cell.set(galleryController: galleryController)
            cell.selectionStyle = .none

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.privateCellID) as! PrivateProfileCell
            
            cell.selectionStyle = .none

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || !self.isAllowedAccess {
            return UITableView.automaticDimension
        } else {
            let rows = CGFloat(galleryController.galleryStrings.count / 3) + 1
            let height = rows * galleryController.cellSize
            return height
        }
    }
}

extension ProfileController: TopProfileCellDelegate {
    func followersTapped() {
        print("followers tapped")
        let followersVC = FollowersViewController(user: self.user)
        self.navigationController?.pushViewController(followersVC, animated: true)
    }
    
    func followButtonTapped() {
        print("follow tapped")
        if self.isFollowing {
            self.profileInteractor.unfollow(followedID: self.user.userID)
            self.isFollowing = false
            self.tableView.reloadData()
        } else {
            self.profileInteractor.attemptToFollow(followedID: self.user.userID)
            self.hasRequested = true
            self.reloadUserData(self)
        }
    }
    
    func challengeButtonTapped() {
        print("challenge tapped")
        self.tabBarController?.selectedIndex = 2
    }
    
    func editProfileTapped() {
        print("edit profile tapped")
        let vc = EditProfileController(user: User(user: user))
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileController: ProfileInteractorDelegate {
    func didRecieveUser(user: User) {
        self.user = user
        self.tableView.reloadData()
    }
    
    func didRecieveFollowersData(followers: Int) {
        self.followers = followers
    }
    
    func didRecieveRequestData(didRequest: Bool) {
        print("did recieve request bool \(didRequest)")
        self.hasRequested = didRequest
        self.tableView.reloadData()
    }
    
    func updateSuccess(_ user: User) {
        self.user = user
        for followUser in userManager.following {
            if followUser.followedID == user.userID {
                self.isFollowing = true
                self.hasRequested = false
            }
        }
        
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }
    
    func updateFailure(_ error: Error) {
        print("error refreshing user: \(error)")
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }
    
    func uploadedAvaterImage(with ID: String) {
        return
    }
    
    func failedToUploadAvatarImage(_ error: Error) {
        return
    }
}

extension ProfileController: MFMailComposeViewControllerDelegate {
    func createReportEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["exhbtmain@gmail.com"])
            mail.setSubject("Reporting User \(user.userID)")
            mail.setMessageBody("Please describe why you're reporting this user.\n\n\n\nDo not edit below this.\nUser ID: \(user.userID)", isHTML: false)

            self.present(mail, animated: true)
        } else {
            self.presentAlert(title: "Error reporting user.", message: "Please try again soon.")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
