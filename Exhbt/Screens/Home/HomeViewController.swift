//
//  HomeViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 20/06/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

class HomeViewController: UIViewController {
    var viewModel: HomeViewModel!

    var feedsViewController: FeedsViewController!
    var flashViewController: UIHostingController<FlashView>!

    private lazy var segmentedControl: UISegmentedControl = {
        let items = ["Feeds", "Flash"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.addTarget(self, action: #selector(didChangeSegment(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setImage(UIImage.embedText(toImage: UIImage(systemName: "hand.thumbsup.fill")!, string: "Feeds", color: .black), forSegmentAt: 0)
        segmentedControl.setImage(UIImage.embedText(toImage: UIImage(systemName: "bolt.fill")!, string: "Flash", color: .black), forSegmentAt: 1)

        return segmentedControl
    }()

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSubscribers()

        viewModel.loadNotificationsBadgeCount()
    }

    // MARK: - Actions

    @objc
    private func didChangeSegment(_ segmentedControl: UISegmentedControl) {
        debugLog(self, #function)
        UserSettings.shared.shouldShowFlashAtLaunch.toggle()

        if UserSettings.shared.shouldShowFlashAtLaunch {
            feedsViewController.willMove(toParent: nil)
            feedsViewController.view.removeFromSuperview()
            feedsViewController.removeFromParent()

            displayFlash()

        } else {
            flashViewController.willMove(toParent: nil)
            flashViewController.view.removeFromSuperview()
            flashViewController.removeFromParent()

            displayFeeds()
        }
    }

    func setupInitialView() {
        if UserSettings.shared.shouldShowFlashAtLaunch {
            displayFlash()
            segmentedControl.selectedSegmentIndex = 1

        } else {
            displayFeeds()
            segmentedControl.selectedSegmentIndex = 0
        }
    }
}

// MARK: - Setup

private extension HomeViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default

        navigationItem.titleView = segmentedControl

        setupNotificationsButton()
        setupInitialView()
    }

    func setupSubscribers() {
        viewModel.badgeCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.setupNotificationsButton(withBadgeCount: count)
                UIApplication.shared.applicationIconBadgeNumber = count
            }
            .store(in: &cancellables)

        AppState.shared.shouldRefreshNotificationsBadgeCount
            .sink { _ in
                self.viewModel.loadNotificationsBadgeCount()
            }
            .store(in: &cancellables)
    }

    func displayFeeds() {
        guard let feedsView = feedsViewController.view else { return }
        feedsView.translatesAutoresizingMaskIntoConstraints = false

        addChild(feedsViewController)
        view.addSubview(feedsView)

        NSLayoutConstraint.activate([
            feedsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            feedsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            feedsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            feedsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        feedsViewController.didMove(toParent: self)

        tabBarController?.tabBar.items![0].image = UIImage(systemName: "hand.thumbsup")
        tabBarController?.tabBar.items![0].selectedImage = UIImage(systemName: "hand.thumbsup.fill")

        title = "Vote"
    }

    func displayFlash() {
        guard let flashView = flashViewController.view else { return }

        flashView.translatesAutoresizingMaskIntoConstraints = false

        addChild(flashViewController)
        view.addSubview(flashView)

        NSLayoutConstraint.activate([
            flashView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            flashView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            flashView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            flashView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        flashViewController.didMove(toParent: self)

        tabBarController?.tabBar.items?.first?.image = UIImage(systemName: "bolt")
        tabBarController?.tabBar.items?.first?.selectedImage = UIImage(systemName: "bolt.fill")

        title = "Flash"
    }
}

// MARK: - Notification Button

private extension HomeViewController {
    func badgeLabel(withCount count: Int, badgeSize size: CGFloat) -> UILabel {
        let badgeCount = UILabel(frame: CGRect(x: 0, y: 0, width: size, height: size))
        badgeCount.translatesAutoresizingMaskIntoConstraints = false
        badgeCount.layer.cornerRadius = badgeCount.bounds.size.height / 2
        badgeCount.textAlignment = .center
        badgeCount.layer.masksToBounds = true
        badgeCount.textColor = .white
        badgeCount.font = badgeCount.font.withSize(12)
        badgeCount.backgroundColor = .systemRed
        badgeCount.text = String(count)
        return badgeCount
    }

    func setupNotificationsButton(withBadgeCount badgeCount: Int = 0) {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "bell.fill",
                                      withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
        let button = UIButton(configuration: configuration, primaryAction: UIAction { _ in
            self.presentNotifications()
        })

        if badgeCount > 0 {
            let badgeSize: CGFloat = 18

            let badge = badgeLabel(withCount: badgeCount, badgeSize: badgeSize)
            button.addSubview(badge)

            NSLayoutConstraint.activate([
                badge.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 24),
                badge.bottomAnchor.constraint(equalTo: button.topAnchor, constant: 20),
                badge.widthAnchor.constraint(equalToConstant: badgeSize),
                badge.heightAnchor.constraint(equalToConstant: badgeSize),
            ])
        }

        let item = UIBarButtonItem(customView: button)

        navigationItem.rightBarButtonItem = item
    }
}

// MARK: - Router

extension HomeViewController: Router {}
