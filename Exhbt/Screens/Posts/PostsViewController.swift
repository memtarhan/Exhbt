//
//  PostsViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/12/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import Contacts
import SwiftUI
import UIKit

class PostsViewController: BaseViewController, Nibbable {
    var viewModel: PostsViewModel!

    var eventId: Int?

    @IBOutlet var tableView: UITableView!
    @IBOutlet var postButtonImageView: UIImageView!
    private let refreshControl = UIRefreshControl()

    private lazy var dataSource = generatedDataSource
    private lazy var sections = EventPostSection.allCases

    private var cancellables: Set<AnyCancellable> = []

    private let rowHeight: CGFloat = 300

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let eventId else {
            return dismiss(animated: true)
        }

        setupUI()
        setupSubscribers()

        viewModel.eventId = eventId
        viewModel.registerNotifications()
        viewModel.loadEventDetails()
        viewModel.load()
    }

    // MARK: - Actions

    @objc
    private func didPullToRefresh() {
        refreshControl.beginRefreshing()
        viewModel.refresh()
    }

    @objc
    private func didTapPost() {
        ContentCreation.display(on: self, forContentType: .photoAndVideo) { _, asset, _ in
            if let asset {
                self.startLoading()
                self.viewModel.post(asset: asset)
            }
        }
    }

    @objc
    private func didTapInvite() {
        let permission = CNContactStore.authorizationStatus(for: .contacts)
        if permission == .notDetermined {
            presentNewCompetitionStatus(withType: .contacts, fromSource: self)
        } else if permission == .authorized {
            guard let eventId else { return }
            presentInvite(eventId: eventId)
        } else {
            stopLoading(withResult: .failure(.getType()))
        }
    }

    private func displayDeleteAlert(forPost post: PostDisplayModel) {
        let alertController = UIAlertController(title: "Delete post?", message: "Are you sure you want to delete your post?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.startLoading()
            self?.viewModel.delete(post: post)
        }
        alertController.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    private var generatedDataSource: UITableViewDiffableDataSource<EventPostSection, DisplayModel> {
        let dataSource = UITableViewDiffableDataSource<EventPostSection, DisplayModel>(tableView: tableView) { _, indexPath, model in

            let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostRow", for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            guard let post = model as? PostDisplayModel else { return cell }

            cell.contentConfiguration = UIHostingConfiguration {
                PostView(post: post, onDelete: {
                    self.displayDeleteAlert(forPost: post)
                })
            }
            .margins([.leading, .trailing], 8)
            .margins([.top, .bottom], 4)

            return cell
        }

        return dataSource
    }
}

private extension PostsViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .systemBlue

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PostRow")
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = 500
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.keyboardDismissMode = .onDrag

        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        postButtonImageView.isUserInteractionEnabled = true
        postButtonImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPost)))

        startLoading()
    }

    func setupSubscribers() {
        viewModel.event
            .receive(on: DispatchQueue.main)
            .sink { event in
                self.navigationItem.title = event.title

                if event.isOwn {
                    let inviteButton = UIBarButtonItem(title: "Invite", style: .done, target: self, action: #selector(self.didTapInvite))
                    self.navigationItem.rightBarButtonItem = inviteButton
                }
            }
            .store(in: &cancellables)

        viewModel.snapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { snapshot in
                self.dismissEmtypState()
                self.dataSource.apply(snapshot, animatingDifferences: false)
                self.stopLoading()
                self.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)

        viewModel.shouldDisplayEmptyState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.stopLoading()
                self?.displayEmptyState(withType: .posts)
            }
            .store(in: &cancellables)
        
        viewModel.displayFailedToDelete
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.stopLoading()
                self?.displayAlert(withTitle: "Failed to delete the post", message: "Please, try again.")
            }
            .store(in: &cancellables)
        
    }
}

extension PostsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        ((tableView.frame.width) * viewModel.getAspectRatio(atIndexPath: indexPath)) + 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        viewModel.didSelectItem(atIndexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //        viewModel.willDisplayItem(atIndexPath: indexPath)
    }
}

extension PostsViewController: NewCompetitionStatusDelegate {
    func newCompetitionStatusDidDismiss(withSuccess success: Bool) {
        guard let eventId else { return }
        if success {
            DispatchQueue.main.async {
                self.presentInvite(eventId: eventId)
            }
        } else { debugLog(self, "Failed to access contacts") }
        // TODO: Handle Contact request
    }
}

// MARK: - Router

extension PostsViewController: Router { }
