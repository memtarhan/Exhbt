//
//  MissingAccountDetailsViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 03/09/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

class MissingAccountDetailsViewController: BaseViewController, Nibbable {
    var viewModel: MissingAccountDetailsViewModel!

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var profilePhotoImageView: CircleImageView!
    @IBOutlet var addPhotoButton: UIButton!
    @IBOutlet var createAccountButton: FilledButton!

    @Published var didAddPhoto = PassthroughSubject<Bool, Never>()
    @Published var addedAsset = CurrentValueSubject<CCAsset?, Never>(nil)
    @Published var didAddDetails = PassthroughSubject<Bool, Never>()
    @Published var shouldEnableCreateButton = CurrentValueSubject<Bool, Never>(false)

    private var cancellables: Set<AnyCancellable> = []

    private var entries: MissingAccountDetailsEntries?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSubscribers()
    }

    @IBAction func didTapAddPhoto(_ sender: UIButton) {
        ContentCreation.display(on: self) { _, asset, _ in
            if let asset {
                self.addedAsset.send(asset)
                self.didAddPhoto.send(true)
            }
        }
    }

    @IBAction func didTapCreate(_ sender: UIButton) {
        startLoading()
        guard let entries else { return }
        viewModel.createAccount(withAsset: addedAsset.value, entries: entries)
    }
}

// MARK: - Setup

private extension MissingAccountDetailsViewController {
    func setupUI() {
        navigationItem.title = "Finish Your Account"
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default

        let detailsContentView = MissingAccountDetailsContentView { [weak self] entries in
            self?.entries = entries
            self?.didAddDetails.send(entries.username != "")
        }
        let hosting = UIHostingController(rootView: detailsContentView)
        guard let contentView = hosting.view else { return }

        contentView.translatesAutoresizingMaskIntoConstraints = false

        addChild(hosting)
        view.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: createAccountButton.topAnchor),
        ])

        hosting.didMove(toParent: self)
    }

    func setupSubscribers() {
        didAddDetails.receive(on: DispatchQueue.main)
            .sink { added in
                self.shouldEnableCreateButton.send(added)
            }
            .store(in: &cancellables)

        didAddPhoto.receive(on: DispatchQueue.main)
            .sink { _ in
                self.addPhotoButton.setTitle("Update Profile Photo", for: .normal)
            }
            .store(in: &cancellables)

        addedAsset
            .receive(on: DispatchQueue.main)
            .sink { [weak self] asset in
                guard let self = self,
                      let asset = asset else { return }
                self.didAddPhoto.send(true)
                self.profilePhotoImageView.image = asset.image
            }
            .store(in: &cancellables)

        shouldEnableCreateButton
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: createAccountButton)
            .store(in: &cancellables)

        viewModel.shouldNavigateToHome
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.stopLoading()
                self?.presentTabBar()
            }
            .store(in: &cancellables)

        viewModel.failedToUpdateUsername
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.stopLoading()
                let alertController = UIAlertController(title: "Failed to save username", message: "Please enter another username", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                alertController.addAction(okAction)

                self?.present(alertController, animated: true)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Router

extension MissingAccountDetailsViewController: Router {}
