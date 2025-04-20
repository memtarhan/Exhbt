//
//  NotificationsViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 17/09/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

class NotificationsViewController: BaseViewController, Nibbable {
    var viewModel: NotificationsViewModel!

    // MARK: - IBOutlets

    @IBOutlet var tableView: UITableView!

    private lazy var dataSource = generatedDataSource

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.applicationIconBadgeNumber = 0

        setup()
        setupReactiveComponents()

        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default

        // Reset iOS badge number (and clear all app notifications)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppState.shared.shouldRefreshNotificationsBadgeCount.send() // This is displayed in Feeds
    }

    @objc func didTapMore(_ sender: UIBarButtonItem) {
        debugLog(self, #function)

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let readAction = UIAlertAction(title: "Mark All as Read", style: .default, handler: { [weak self] _ in
            self?.viewModel.markAllAsRead()
        })
        actionSheet.addAction(readAction)

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(actionSheet, animated: true)
    }

    @objc func didTapBack(_ sender: UIBarButtonItem) {
        debugLog(self, #function)
        dismiss(animated: true)
    }

    private func setup() {
        title = "Notifications"

        let rightButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: #selector(didTapMore(_:)))
        rightButtonItem.tintColor = .systemBlue

        navigationItem.rightBarButtonItem = rightButtonItem

        let leftButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .done, target: self, action: #selector(didTapBack(_:)))
        leftButtonItem.tintColor = .systemBlue

        navigationItem.leftBarButtonItem = leftButtonItem

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NotificationRow")

        tableView.delegate = self
        tableView.dataSource = dataSource

        startLoading()
    }

    private func setupReactiveComponents() {
        viewModel.snapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { snapshot in
                self.stopLoading()
                self.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)

        viewModel.shouldDisplayEmptyState
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.stopLoading()
                self.displayEmptyState(withType: .notifications)
            }
            .store(in: &cancellables)

        viewModel.willPresentUser
            .receive(on: DispatchQueue.main)
            .sink { userId in
                self.presentUser(withId: userId)
            }
            .store(in: &cancellables)

        viewModel.willPresentExhbtDetails
            .receive(on: DispatchQueue.main)
            .sink { exhbtId in
                self.presentExhbt(withId: exhbtId, displayMode: .editing) // TODO: Make displayMode dynamic
            }
            .store(in: &cancellables)

        viewModel.willPresentExhbtResult
            .receive(on: DispatchQueue.main)
            .sink { exhbtId in
                self.presentExhbtResult(withId: exhbtId)
            }
            .store(in: &cancellables)

        viewModel.willPresentJoinExhbt
            .receive(on: DispatchQueue.main)
            .sink { exhbtId in
                self.presentNewCompetition(withExhbt: exhbtId, type: .joinWithInvitation, delegate: nil)
            }
            .store(in: &cancellables)

        viewModel.willPresentJoinEvent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] eventId in
                self?.presentEvent(eventId: eventId)
            }
            .store(in: &cancellables)

        viewModel.willPresentEventResult
            .receive(on: RunLoop.main)
            .sink { [weak self] eventId in
                self?.presentEventResult(eventId: eventId)
            }
            .store(in: &cancellables)

        viewModel.eligibleToJoinPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] eligible in
                self?.stopLoading()
                if !eligible {
                    self?.displayIneligibilityAlert(message: "You do not have enough coins to join this Event but you can earn coins with Flash game", completion: {
                        self?.dismiss(animated: true)
                        UserSettings.shared.shouldShowFlashAtLaunch = true
                        AppState.shared.shouldShowFlash.send()
                    })
                }
            }
            .store(in: &cancellables)

        viewModel.joinedPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] joined, eventId in
                self?.stopLoading()
                if joined {
                    self?.presentPosts(forEvent: eventId)
                } else {
                    self?.displayAlert(withTitle: "Oops, failed to join", message: "Please, try again later.", completion: nil)
                }
            })
            .store(in: &cancellables)
    }

    private var generatedDataSource: NoticationsTableViewDiffableDataSource {
        NoticationsTableViewDiffableDataSource(tableView: tableView) { tableView, _, model -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationRow")!

            cell.contentConfiguration = UIHostingConfiguration {
                NotificationRow(data: model)
            }
            .margins([.leading, .trailing], 20)
            .margins([.top, .bottom], 0)
            .background(model.backgroundColor)

            return cell
        }
    }
}

// MARK: - Router

extension NotificationsViewController: Router {}

// MARK: - UITableViewDelegate

extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(atIndexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.willDisplayItem(atIndexPath: indexPath)
    }
}

class NoticationsTableViewDiffableDataSource: UITableViewDiffableDataSource<NotificationSection, NotificationDisplayModel> {}
