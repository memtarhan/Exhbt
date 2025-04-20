//
//  UpdateUserProfileViewController.swift
//  Exhbt
//
//  Created by Rakhmatov Bekzod on 22/04/23.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

class UpdateProfileViewController: BaseViewController, Nibbable {
    var viewModel: UpdateProfileViewModel!

    @IBOutlet var textField: UITextField!

    var fieldType: UpdateProfileFieldType!

    private var hasEdited = CurrentValueSubject<Bool, Never>(false)

    private var cancellables: Set<AnyCancellable> = []

    private var defaultValue: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationBar()
        setupSubscribers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.prefersLargeTitles = false
    }

    // MARK: - Actions

    @objc func didTapSave(_ sender: UIBarButtonItem) {
        viewModel.update(forFieldType: fieldType, value: textField.text)
    }

    @objc func didChangeTextField(_ textField: UITextField) {
        hasEdited.send(textField.text != defaultValue)
    }

    private func setupSubscribers() {
        hasEdited
            .receive(on: DispatchQueue.main)
            .sink { [weak self] edited in
                self?.navigationItem.rightBarButtonItem?.isEnabled = edited
            }
            .store(in: &cancellables)

        viewModel.updated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updated, status in
                self?.displayAlert(withTitle: status, message: nil, completion: {
                    NotificationCenter.default.post(name: .didUpdateProfile, object: nil)
                    if updated {
                        self?.navigationController?.popViewController(animated: true)
                    }
                })
            }
            .store(in: &cancellables)
    }

    func setup() {
        setupNavigationBar()
        textField.addTarget(self, action: #selector(didChangeTextField(_:)), for: .editingChanged)

        defaultValue = fieldType.defaultValue
        textField.placeholder = fieldType.placeholder
        textField.text = defaultValue

        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupNavigationBar() {
        navigationItem.title = fieldType.title

        let rightButtonItem = UIBarButtonItem(
            title: "Update",
            style: .done,
            target: self,
            action: #selector(didTapSave(_:))
        )
        rightButtonItem.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = rightButtonItem
    }
}

extension UpdateProfileViewController: Router {}
