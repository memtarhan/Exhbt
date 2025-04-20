//
//  TabBarViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 21/07/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class TabBarViewController: UITabBarController {
    var viewModel: TabBarViewModel!

    private let layerHeight = CGFloat()
    private lazy var middleButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 19, weight: .regular, scale: .large)
        button.setImage(UIImage(systemName: "plus.rectangle", withConfiguration: configuration), for: .normal)
        button.imageView?.tintColor = .white
        button.backgroundColor = .systemBlue
        return button
    }()

    private lazy var popupView: CreatePopupView = {
        let view = CreatePopupView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        debugLog(self, #function)
        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.listenToInvitation()
        viewModel.listenToNotifications()
        viewModel.syncDeviceTokenIfNeeded()

        viewModel.shouldShowNewCompetition
            .receive(on: DispatchQueue.main)
            .sink { [weak self] exhbtId in
                self?.presentExhbt(withId: exhbtId, displayMode: .viewing, competitionMode: .joinWithInvitation)
//                self?.presentNewCompetition(withExhbt: exhbtId, type: .joinWithInvitation)
            }
            .store(in: &cancellables)

        viewModel.shouldShowAlert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.displayAlert(withTitle: "Invitation expired", message: "This invitations is expired")
            }
            .store(in: &cancellables)

        viewModel.shouldPresentNotifications
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.presentNotifications()
            }
            .store(in: &cancellables)
    }

    func setup() {
        tabBar.tintColor = .systemBlue

        setViewControllers(tabs, animated: false)
        addMiddleButton()

        popupView.delegate = self

        AppState.shared.shouldShowFlash
            .receive(on: DispatchQueue.main)
            .sink { _ in
                let shouldReload = self.selectedIndex == 0
                self.selectedIndex = 0
                if shouldReload {
                    ((self.viewControllers?[0] as? UINavigationController)?.viewControllers.first as? HomeViewController)?.setupInitialView()
                }
            }
            .store(in: &cancellables)
    }

    private var tabs: [UIViewController] {
        return Tab.allCases.map { $0.view }
    }

    private func addMiddleButton() {
//        middleButton.removeFromSuperview()

        // DISABLE TABBAR ITEM - behind the "+" custom button:
        DispatchQueue.main.async {
            if let items = self.tabBar.items {
                items[2].isEnabled = false
            }
        }

        // shape, position and size
        tabBar.addSubview(middleButton)
        let size = CGFloat(64)
        let constant: CGFloat = -10 + (layerHeight / 2) - 5

        // set constraints
        let constraints = [
            middleButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            middleButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor, constant: -constant),
            middleButton.heightAnchor.constraint(equalToConstant: size),
            middleButton.widthAnchor.constraint(equalToConstant: size),
        ]
        for constraint in constraints {
            constraint.isActive = true
        }
        middleButton.layer.cornerRadius = size / 2

        // shadow
        middleButton.layer.shadowColor = UIColor.gray.cgColor
        middleButton.layer.shadowOffset = CGSize(width: 0,
                                                 height: 8)
        middleButton.layer.shadowOpacity = 0.75
        middleButton.layer.shadowRadius = 13

        // other
        middleButton.layer.masksToBounds = false
        middleButton.translatesAutoresizingMaskIntoConstraints = false

        // action
        middleButton.addTarget(self, action: #selector(buttonHandler(sender:)), for: .touchUpInside)
    }

    @objc func buttonHandler(sender: Any) {
        if popupView.superview == nil {
            view.insertSubview(popupView, at: 1)

            NSLayoutConstraint.activate([
                popupView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -120),
                popupView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                popupView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                popupView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            ])

        } else {
            popupView.removeFromSuperview()
        }
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        popupView.removeFromSuperview()
    }
}

// MARK: - Router

extension TabBarViewController: Router {}

// MARK: - NewExhbtDelegate

extension TabBarViewController: NewExhbtDelegate {
    func newExhbtWillDismiss(_ exhbtId: Int, exhbtType type: ExhbtType) {
        debugLog(self, #function)
        presentNewExhbtPopup(exhbtId: exhbtId, exhbtType: type, delegate: self)
    }

    func newExhbtWillShowChooseCompetitors(_ exhbtId: Int) {
        debugLog(self, #function)
        presentChooseCompetitors(exhbtId: exhbtId, delegate: self)
    }
}

// MARK: - ChooseCompetitorsDelegate

extension TabBarViewController: ChooseCompetitorsDelegate {
    func chooseCompetitorsWillDismiss() {
        debugLog(self, #function)
    }
}

// MARK: - CreatePopupViewDelegate

extension TabBarViewController: CreatePopupViewDelegate {
    func createPopupWillCreateExhbt() {
        debugLog(self, #function)
        presentNewExhbt(delegate: self)
        popupView.removeFromSuperview()
    }

    func createPopupWillCreateEvent() {
        debugLog(self, #function)
        presentNewEvent()
        popupView.removeFromSuperview()
    }

    func createPopupWillDismiss() {
        debugLog(self, #function)
        popupView.removeFromSuperview()
    }
}

enum Tab: Int, CaseIterable {
    case home = 0
    case explore
    case newExhbt
    case leaderboard
    case profile

    private var factory: ViewControllerFactoryProtocol {
        (AppAssembler.shared.assembler?.resolver.resolve(ViewControllerFactoryProtocol.self))!
    }

    var view: UIViewController {
        switch self {
        case .home:
            let feeds = factory.home
//            feeds.tabBarItem = UITabBarItem(title: "Vote", image: UIImage(systemName: "hand.thumbsup"), selectedImage: UIImage(systemName: "hand.thumbsup.fill"))
            return UINavigationController(rootViewController: feeds)

        case .explore:
            let explore = factory.explore
            explore.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "magnifyingglass"), selectedImage: UIImage(systemName: "magnifyingglass"))
            return UINavigationController(rootViewController: explore)

        case .newExhbt:
            let newExhbt = UIViewController()
            newExhbt.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "plus.circle"), selectedImage: UIImage(systemName: "plus.circle.fill"))
            return UINavigationController(rootViewController: newExhbt)

        case .leaderboard:
            let leaderboard = factory.leaderboard
            leaderboard.tabBarItem = UITabBarItem(title: "Leaderboard", image: UIImage(systemName: "crown"), selectedImage: UIImage(systemName: "crown.fill"))
            return UINavigationController(rootViewController: leaderboard)

        case .profile:
            let profile = factory.me
            profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
            return UINavigationController(rootViewController: profile)
        }
    }
}
