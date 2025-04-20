//
//  ExhbtViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 28/08/2022.
//  Copyright © 2022 Exhbt LLC. All rights reserved.
//

import Combine
import Contacts
import UIKit

class ExhbtViewController: BaseViewController, Nibbable {
    var viewModel: ExhbtViewModel!

    var exhbtId: Int?

    /// - Exhbt View
    @IBOutlet var containerView: CardView!
    @IBOutlet var imagesContentView: HorizontalPhotosView!
    @IBOutlet var categoryView: UIView!
    @IBOutlet var statusStackView: UIStackView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var statusView: UIView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var statusDotView: UIImageView!
    @IBOutlet var timeLeftLabel: UILabel!

    @IBOutlet var exhbtStatusView: ExhbtStatusView!

    @IBOutlet var competitorsView: ExhbtCompetitorsView!

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupReactiveComponents()
        guard let exhbtId else {
            dismiss(animated: true)
            return
        }
        viewModel.loadData(forExhbt: exhbtId)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .systemBlue
    }

    // MARK: - Actions

    func displayInviteCompetitors() {
        let permission = CNContactStore.authorizationStatus(for: .contacts)
        if permission == .notDetermined {
            presentNewCompetitionStatus(withType: .contacts, fromSource: self)
        } else if permission == .authorized {
            guard let exhbtId else { return }
            presentChooseCompetitors(exhbtId: exhbtId, delegate: nil)
        } else {
            self.stopLoading(withResult: .failure(.getType()))
        }
    }

    private func setup() {
        competitorsView.delegate = self

        imagesContentView.makeRounded()

        categoryView.makeCircle()

        statusView.makeCircle()
        statusView.layer.borderWidth = 0.3
        statusView.layer.borderColor = UIColor.white.cgColor

        let reportButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: #selector(didTapReport(_:)))
        navigationItem.rightBarButtonItems = [reportButton]
    }

    private func setupReactiveComponents() {
        viewModel.title
            .receive(on: DispatchQueue.main)
            .sink { title in
                self.navigationItem.title = title
            }
            .store(in: &cancellables)

        viewModel.media
            .receive(on: DispatchQueue.main)
            .sink { data in
                self.imagesContentView.id = data.exhbtId
                self.imagesContentView.update(models: data.content)
            }
            .store(in: &cancellables)

        viewModel.category
            .receive(on: DispatchQueue.main)
            .sink { data in
                self.categoryLabel.text = data
            }
            .store(in: &cancellables)

        viewModel.timeLeft
            .receive(on: DispatchQueue.main)
            .sink { data in
                self.timeLeftLabel.text = data
            }
            .store(in: &cancellables)

        viewModel.status
            .receive(on: DispatchQueue.main)
            .sink { data in
                self.statusLabel.text = data.title
                if data == .finished {
                    self.statusDotView.isHidden = true
                }
            }
            .store(in: &cancellables)

        viewModel.exhbtStatus
            .receive(on: DispatchQueue.main)
            .sink { status in
                self.exhbtStatusView.update(withModel: status)
                self.competitorsView.update()
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func didTapReport(_ sender: UIBarButtonItem) {
        ReportActionService.shared.reportActionServiceDidFinishReporting
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.viewModel.flag()
            }
            .store(in: &cancellables)
        ReportActionService.shared.display(on: self)
    }
}

// MARK: - Navigations

extension ExhbtViewController: Router { }

// MARK: - NewCompetitionStatusDelegate

extension ExhbtViewController: NewCompetitionStatusDelegate {
    func newCompetitionStatusDidDismiss(withSuccess success: Bool) {
        if success,
           let exhbtId {
            DispatchQueue.main.async {
                self.presentChooseCompetitors(exhbtId: exhbtId, delegate: nil)
            }
        }
    }
}

// MARK: - HorizontalCompetitorsDelegate

extension ExhbtViewController: ExhbtCompetitorsDelegate {
    func exhbtCompetitorsDidViewInfo() {
        presentCompetitionsInfoPopup()
    }

    func exhbtCompetitorsWillAddCompetitors() {
        displayInviteCompetitors()
    }

    func exhbtCompetitors(willViewUser user: Int) {
        presentUser(withId: user)
    }
}
