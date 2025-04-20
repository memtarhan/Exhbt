//
//  OnboardingViewController.swift
//  Exhbt
//
//  Created by hilmideprem on 18.08.2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

class OnboardingViewController: UIViewController {
    private var hostingController: UIHostingController<OnboardingContentView>!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
}

// MARK: - Setup

private extension OnboardingViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default

        let imageView = UIImageView(image: UIImage(named: "Navigation Bar - Logo"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView

        displayContent()
    }

    func displayContent() {
        let contentView = OnboardingContentView { [weak self] in
            guard let self else { return }
            self.presentSignIn()
        }
        hostingController = UIHostingController(rootView: contentView)

        guard let flashView = hostingController.view else { return }

        flashView.translatesAutoresizingMaskIntoConstraints = false

        addChild(hostingController)
        view.addSubview(flashView)

        NSLayoutConstraint.activate([
            flashView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            flashView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            flashView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            flashView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        hostingController.didMove(toParent: self)
    }
}

extension OnboardingViewController: Router { }
