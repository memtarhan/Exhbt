//
//  LeaderboardViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 11/03/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

final class LeaderboardViewController: UIViewController {
    var viewModel: LeaderboardViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
        setupHandlers()
        viewModel.loadTags()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}

// TODO: Fix it by removing handler and placing combine publisher
private extension LeaderboardViewController {
    func setupHandlers() {
        viewModel.navigationAction = { [weak self] userId in
            if userId == UserSettings.shared.id {
                self?.tabBarController?.selectedIndex = (self?.tabBarController?.viewControllers?.count ?? 5) - 1
                
            } else {
                self?.presentUser(withId: userId)
            }
            
        }
    }

    func setupSwiftUIView() {
        let view = LeaderboardScene(viewModel: self.viewModel)

        let hostingController = UIHostingController(rootView: view)

        addChild(hostingController)
        self.view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])

        hostingController.didMove(toParent: self)
    }
}

extension LeaderboardViewController: Router {}
