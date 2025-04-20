//
//  ProfileAccountViewController.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 08/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class ProfileAccountViewController: BaseViewController, Nibbable {
    var viewModel: ProfileAccountViewModel!

    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeight: NSLayoutConstraint!
    @IBOutlet var profileImageView: CircleImageView!

    private var cancellables: Set<AnyCancellable> = []
    private let rowHeight: CGFloat = 44

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        registerNotifications()
    }

    private func registerNotifications() {
        viewModel.updateUserProfile()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateProfile(_:)),
                                               name: .didUpdateProfile,
                                               object: nil)
    }

    @objc private func updateProfile(_ sender: Notification) {
        viewModel.updateUserProfile()
    }

    func setup() {
        title = "Profile & Account"
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        tableView.register(UINib(nibName: ButtonTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ButtonTableViewCell.identifier)
        tableView.register(UINib(nibName: NormalTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: NormalTableViewCell.identifier)
        tableView.register(UINib(nibName: TitleIconTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TitleIconTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self

        viewModel.updateTableView
            .sink { [weak self] height in
                guard let self = self else { return }
                if let height = height {
                    tableViewHeight.constant = height
                }
                tableView.reloadData()
                profileImageView.loadImage(urlString: UserSettings.shared.profilePhotoThumbnail)
            }
            .store(in: &cancellables)

        viewModel.deletedAccountPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.stopLoading()
                switch completion {
                case .finished:
                    self?.presentSignIn()
                case .failure:
                    self?.displayWarningAlert(withTitle: "Failed to delete your account", message: "Please, try again.", completion: {
                    })
                }
            } receiveValue: { _ in
            }
            .store(in: &cancellables)
    }

    @IBAction func didTapProfilePhoto() {
        viewModel.isProfileImage = true
        // TODO: Display preview of photo
        ContentCreation.display(on: self) { _, asset, _ in
            self.viewModel.addedAsset.send(asset)
            self.profileImageView.image = asset?.image
        }
    }
}

extension ProfileAccountViewController: VoteStyleViewerDelegate {
    func voteStyleViewer(didSelectVoteStyle style: VoteStyle) {
        viewModel.updateUserProfile()
    }

    func voteStyleViewer(didFailWithError error: Error) {
    }
}

// MARK: - UITableViewDelegate

extension ProfileAccountViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = viewModel.profileList[indexPath.section].items[indexPath.row]
        debugLog(self, data.type.displayName())
        switch data.type {
        case .name:
            presentUpdateProfile(profileFieldType: .fullName)
            break
        case .username:
            presentUpdateProfile(profileFieldType: .username)
            break
        case .aboutMe:
            presentUpdateProfile(profileFieldType: .bio)
            break
        case .voteStyle:
            presentVoteStyles(on: self)
            break
        case .email:
            break
        case .loginOption:
            break
        case .password:
            break
        case .delete:
            displayWarningAlert(
                withTitle: "Delete Account",
                message: "Are you sure you want to Delete your account?") { [weak self] in
                    self?.startLoading()
                    self?.viewModel.delete()
                }
            break
        }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        viewModel.profileList[section].headerHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeight
    }
}

// MARK: - UITableViewDataSource

extension ProfileAccountViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.profileList[section].section
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.profileList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.profileList[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = viewModel.profileList[indexPath.section].items[indexPath.row]
        if data.type == .delete {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath) as? ButtonTableViewCell {
                cell.titleLabel.text = data.type.displayName()
                cell.titleLabel.textColor = .red
                return cell
            }
        } else if data.type == .voteStyle {
            if let cell = tableView.dequeueReusableCell(withIdentifier: TitleIconTableViewCell.identifier, for: indexPath) as? TitleIconTableViewCell {
                cell.titleLabel.text = data.type.displayName()
                cell.iconImageView.image = data.icon
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: NormalTableViewCell.identifier, for: indexPath) as? NormalTableViewCell {
                cell.titleLabel.text = data.type.displayName()
                cell.subtitleLabel.text = data.subtitle
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension ProfileAccountViewController: Router {}
