//
//  NewExhbtSetupViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 05/08/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import Photos
import SwiftUI
import UIKit

class NewExhbtSetupViewController: BaseViewController, Nibbable {
    var viewModel: NewExhbtViewModel!

    var asset: CCAsset!
    var exhbtType: ExhbtType!

    var tags = [String]()
    var exhbtDescription: String?

    @IBOutlet var bottomStackView: UIStackView!
    @IBOutlet var statusButton: ButtonWithMultipleImages!

    @IBOutlet var buttonView: UIView!
    @IBOutlet var createButton: UIButton!

    @IBOutlet var coinIndicationView: UIView!

    @Published var selectedExhbtType = CurrentValueSubject<ExhbtType, Never>(.public)
    @Published var shouldEnableButton = PassthroughSubject<Bool, Never>()

    private var cancellables: Set<AnyCancellable> = []

    weak var delegate: NewExhbtDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSubscribers()

        selectedExhbtType.send(exhbtType)
    }

    @IBAction func didTapCreate(_ sender: UIButton) {
        sender.isEnabled = false
        startLoading()

        if let exhbtDescription {
            viewModel.create(withAsset: asset, tags: tags, description: exhbtDescription, type: selectedExhbtType.value)
        }
    }
}

// MARK: - Setup

private extension NewExhbtSetupViewController {
    func setupUI() {
        navigationItem.title = "Set Up Your Exhbt"
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default

        var image: UIImage?
        switch asset.type {
        case .image:
            image = asset.image!
        case .video:
            image = asset.thumbnail!
        }
        
        let hosting = UIHostingController(rootView: NewExhbtSetupContentView(image: image!, delegate: self))
        guard let contentView = hosting.view else { return }

        contentView.translatesAutoresizingMaskIntoConstraints = false

        addChild(hosting)
        view.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: -20),
        ])

        hosting.didMove(toParent: self)

        statusButton.delegate = self

        coinIndicationView.layer.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1).cgColor
        coinIndicationView.layer.cornerRadius = 12

        displayCoinsCountButton()
    }

    func setupSubscribers() {
        selectedExhbtType
            .receive(on: DispatchQueue.main)
            .sink { type in
                self.statusButton.title = type.title
                self.statusButton.leftImage = type.image
            }
            .store(in: &cancellables)

        shouldEnableButton
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: createButton)
            .store(in: &cancellables)

        viewModel.showCreatedPopup
            .receive(on: DispatchQueue.main)
            .sink { exhbtId in
                self.navigationController?.dismiss(animated: true) {
                    self.delegate?.newExhbtWillDismiss(exhbtId, exhbtType: self.selectedExhbtType.value)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - ButtonWithMultipleImagesDelegate

extension NewExhbtSetupViewController: ButtonWithMultipleImagesDelegate {
    func buttonWithMultipleImagesDidTap() {
        debugLog(self, #function)
        let actions = ExhbtType.allCases.map { type in
            AlertAction(title: type.title, image: type.image, style: .default, handler: { _ in
                self.selectedExhbtType.send(type)
            })
        }

        presentActionSheet(withTitle: "Who can join the competition",
                           message: nil, actions: actions)
    }
}

// MARK: - NewExhbtSetupDelegate

extension NewExhbtSetupViewController: NewExhbtSetupDelegate {
    func newExhbtSetup(didSelecTags tags: [String], description: String?) {
        if let description {
            shouldEnableButton.send((!description.isEmpty) && !tags.isEmpty)
            self.tags = tags
            exhbtDescription = description
        } else {
            shouldEnableButton.send(false)
        }
    }
}
