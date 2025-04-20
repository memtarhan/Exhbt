//
//  ChooseCompetitorsViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 06/10/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

protocol ChooseCompetitorsDelegate: AnyObject {
    func chooseCompetitorsWillDismiss()
}

class ChooseCompetitorsViewController: BaseViewController, Nibbable {
    var viewModel: ChooseCompetitorsViewModel!

    var exhbtId: Int?

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var competitorsView: HorizontalCompetitorsView!
    @IBOutlet var statusButton: ButtonWithMultipleImages!
    @IBOutlet var countView: UIView!
    @IBOutlet var countLabel: UILabel!

    private var cancellables: Set<AnyCancellable> = []
    private var contacts = [DisplayModel]()
    private var friends = [DisplayModel]()
    private var filteredContacts = [DisplayModel]()
    private var filteredFriends = [DisplayModel]()
    private var filtering = false

    weak var delegate: ChooseCompetitorsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()

        guard exhbtId != nil else {
            dismiss(animated: true)
            return
        }
        viewModel.loadFriends()
        viewModel.fetchContacts()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        delegate?.chooseCompetitorsWillDismiss()
    }

    // MARK: - Actions

    @objc func didTapCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction func didTapShare(_ sender: Any) {
        guard let exhbtId else { return }

        startLoading()
        viewModel.handleShareLink(forExhbt: exhbtId)
    }

    @objc func didTapChoose(_ sender: UIBarButtonItem) {
        startLoading()

        guard let exhbtId else { return }
        viewModel.sendInvitations(forExhbt: exhbtId)
    }

    private func setup() {
        setupLayout()
        setupReactiveComponents()
    }

    private func setupLayout() {
        title = "Choose Competitors"

        let leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                style: .plain,
                                                target: self,
                                                action: #selector(didTapCancel(_:)))
        leftBarButtonItem.tintColor = .systemBlue
        navigationItem.leftBarButtonItem = leftBarButtonItem

        let rightButtonItem = UIBarButtonItem(title: "Done",
                                              style: .done,
                                              target: self,
                                              action: #selector(didTapChoose(_:)))
        rightButtonItem.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = rightButtonItem

        let cell = UINib(nibName: ItemWithImageTableViewCell.identifier, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: ItemWithImageTableViewCell.identifier)
        tableView.rowHeight = 64
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag

        searchBar.delegate = self

        competitorsView.delegate = self
        statusButton.delegate = self

        countView.isHidden = true
    }

    private func setupReactiveComponents() {
        viewModel.competitors
            .receive(on: DispatchQueue.main)
            .sink { [weak self] competitors in
                let count = competitors.count

//                self?.navigationItem.rightBarButtonItem?.isEnabled = competitors.count > 1

                if count < 9 {
                    if count > 1 {
                        self?.countView.isHidden = false
                        self?.countLabel.text = "\(count) Contacts Will be Invited to Exhbt"

                    } else {
                        self?.countView.isHidden = true
                    }
                    let models = competitors.map { model in
                        if let model = model as? ContactDisplayModel {
                            return CompetitorPhotoDisplayModel(id: nil, image: model.image, photoURL: model.imageURL, status: .pending, index: nil)

                        } else {
                            let model = model as! FollowingContactDisplayModel
                            return CompetitorPhotoDisplayModel(id: nil, image: model.image, photoURL: model.imageURL, status: .pending, index: nil)
                        }
                    }
                    self?.competitorsView.update(withModels: models)
                }
            }
            .store(in: &cancellables)

        viewModel.link
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                guard let url else {
                    self?.stopLoading(withResult: .failure(.getType()))
                    return
                }
                let items: [Any] = ["You are invited to join a competition on Exhbt. Join here\n\(url)"]
                let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self?.view // so that iPads won't crash

                self?.stopLoading()
                self?.present(activityViewController, animated: true)
            }
            .store(in: &cancellables)

        viewModel.contacts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] contacts in
                self?.contacts = contacts
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.friends
            .receive(on: DispatchQueue.main)
            .sink { [weak self] friends in
                self?.friends = friends
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.shouldDisplayError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.stopLoading(withResult: .failure(.getType()))
            }
            .store(in: &cancellables)

        viewModel.shouldStopLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.stopLoading()
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)

        viewModel.showOpenSettings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.showOpenSettingsPopup()
            }
            .store(in: &cancellables)
    }

    private func showOpenSettingsPopup() {
        let alert = UIAlertController(
            title: "Please Allow Access to your Contacts",
            message: "This Allows Exhbt to choose competitors from your contacts.",
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { success in
                    debugLog(self, "Settings opened: \(success)")
                })
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(openSettingsAction)
        DispatchQueue.main.async {
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = [] // No arrow for the popover
            }
            self.present(alert, animated: true)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ChooseCompetitorsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return filtering ? filteredFriends.count : friends.count
        }
        return filtering ? filteredContacts.count : contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemWithImageTableViewCell.identifier) as!
            ItemWithImageTableViewCell

        cell.subtitleLabel.isHidden = true

        if indexPath.section == 0 {
            let contact = filtering ? filteredFriends[indexPath.row] : friends[indexPath.row]
            cell.titleLabel.text = (contact as? FollowingContactDisplayModel)?.fullName
            cell.photoImageView.image = (contact as? FollowingContactDisplayModel)?.image
        }

        if indexPath.section == 1 {
            let contact = filtering ? filteredContacts[indexPath.row] : contacts[indexPath.row]
            cell.titleLabel.text = (contact as? ContactDisplayModel)?.fullName
            cell.photoImageView.image = (contact as? ContactDisplayModel)?.image
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "FRIENDS ON EXHBT"
        case 1:
            return "FRIENDS NOT ON EXHBT"
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let friend = filtering ? filteredFriends[indexPath.row] : friends[indexPath.row]
            viewModel.addCompetitor(contact: friend)
        } else {
            let contact = filtering ? filteredContacts[indexPath.row] : contacts[indexPath.row]
            viewModel.addCompetitor(contact: contact)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let friend = filtering ? filteredFriends[indexPath.row] : friends[indexPath.row]
            viewModel.removeCompetitor(contact: friend)
        } else {
            let contact = filtering ? filteredContacts[indexPath.row] : contacts[indexPath.row]
            viewModel.removeCompetitor(contact: contact)
        }
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if viewModel.selectionReachedLimit { return nil }
        return indexPath
    }
}

// MARK: - Router

extension ChooseCompetitorsViewController: Router {}

// MARK: - HorizontalCompetitorsDelegate

extension ChooseCompetitorsViewController: HorizontalCompetitorsDelegate {
    func horizontalCompetitorsDidViewInfo() {
        presentCompetitionsInfoPopup()
    }

    func horizontalCompetitors(willViewUser user: Int) { }
}

// MARK: - ButtonWithMultipleImagesDelegate

extension ChooseCompetitorsViewController: ButtonWithMultipleImagesDelegate {
    func buttonWithMultipleImagesDidTap() {
        debugLog(self, #function)
        let actions = [AlertAction(title: "Public, Open to All", image: UIImage(systemName: "globe"), style: .default, handler: { _ in
            self.statusButton.title = "Public, Open to All"
        }),
        AlertAction(title: "Public, Invites Only", image: UIImage(systemName: "envelope"), style: .default, handler: { _ in
            self.statusButton.title = "Public, Invites Only"
        })]
        presentActionSheet(withTitle: "Who can join the competition",
                           message: nil, actions: actions)
    }
}

// MARK: - UISearchBarDelegate

extension ChooseCompetitorsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            filteredFriends = friends.filter({ (($0 as? FollowingContactDisplayModel)?.fullName ?? "").contains(searchText) })
            filtering = true
        } else {
            filtering = false
        }
        tableView.reloadData()
    }
}
