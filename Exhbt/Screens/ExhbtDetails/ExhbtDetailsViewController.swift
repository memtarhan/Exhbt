//
//  ExhbtDetailsViewController.swift
//  Exhbt
//
//  Created by Mehmet Tarhan on 04/04/2023.
//  Copyright © 2023 Exhbt LLC. All rights reserved.
//

import Combine
import UIKit

enum ExhbtDetailsDisplayMode: Int {
    case editing
    case viewing
}

class ExhbtDetailsViewController: BaseViewController, Nibbable {
    var viewModel: ExhbtDetailsViewModel!
    var exhbtId: Int?
    var displayMode = ExhbtDetailsDisplayMode.viewing
    var competitionMode: NewCompetitionType?
    var model: ExhbtPreviewDisplayModel!

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var previewView: ExhbtPreviewView!
    @IBOutlet var statusView: SingleExhbtStatusView!
    @IBOutlet var competitorsView: SingleExhbtCompetitorsView!
    @IBOutlet var submissionsView: SingleExhbtSubmissionsView!
    @IBOutlet var settingsView: SingleExhbtSettingsView!
    @IBOutlet var deleteButton: UIButton!

    private var cancellables: Set<AnyCancellable> = []

    private var timer: Timer?
    private var expirationDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupReactiveComponents()
        setupGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let exhbtId else {
            dismiss(animated: true)
            return
        }

        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.barStyle = .default

        viewModel.loadData(forExhbt: exhbtId)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        timer?.invalidate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func didTapDelete(_ sender: Any) {
        startLoading()
        guard let exhbtId else {
            dismiss(animated: true)
            return
        }
        viewModel.delete(exhbt: exhbtId)
    }

    private func setup() {
        let reportButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: #selector(didTapReport(_:)))
        navigationItem.rightBarButtonItems = [reportButton]

        navigationItem.title = "Exhbt"

        competitorsView.delegate = self

        settingsView.isHidden = true
        
        if displayMode == .viewing {
            previewView.editIconImageView.isHidden = true
            settingsView.disable()
            deleteButton.isHidden = true
        }
    }

    private func setupReactiveComponents() {
        viewModel.expirationDate
            .receive(on: DispatchQueue.main)
            .sink { expirationDate in
                self.expirationDate = expirationDate
//                self.previewView.update(timeLeft: expirationDate.timeLeft)
                self.statusView.update(timeLeft: expirationDate.timeLeft)
                self.previewView.setupTimerLabel(expirationDate)
                self.startTimer()
            }
            .store(in: &cancellables)

        viewModel.preview
            .receive(on: DispatchQueue.main)
            .sink { model in
                self.previewView.update(withModel: model, alreadyInEditMode: false)
                self.model = model
            }
            .store(in: &cancellables)

        viewModel.status
            .receive(on: DispatchQueue.main)
            .sink { model in
                self.statusView.update(withModel: model)
                self.competitorsView.updateJoinButtonStatus(status: model.status, canJoin: model.canJoin, isOwn: model.isOwn)
            }
            .store(in: &cancellables)

        viewModel.competitors
            .receive(on: DispatchQueue.main)
            .sink { model in
                self.competitorsView.update(withModel: model, displayMode: self.displayMode)
                self.deleteButton.isHidden = !model.isOwn
            }
            .store(in: &cancellables)

        viewModel.submissions
            .receive(on: DispatchQueue.main)
            .sink { model in
                self.submissionsView.update(withModel: model)
            }
            .store(in: &cancellables)

        viewModel.settings
            .receive(on: DispatchQueue.main)
            .sink { model in
                self.settingsView.update(withModel: model)
            }
            .store(in: &cancellables)

        viewModel.shouldDisplayError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.stopLoading(withResult: .failure(.getType()))
            }
            .store(in: &cancellables)

        viewModel.deletedExhbt
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.stopLoading()
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc
    private func didTapReport(_ sender: UIBarButtonItem) {
        ReportActionService.shared.reportActionServiceDidFinishReporting
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.viewModel.flag()
            }
            .store(in: &cancellables)
        ReportActionService.shared.display(on: self)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let expirationDate = self?.expirationDate else { return }
//            self?.previewView.update(timeLeft: expirationDate.timeLeft)
            self?.statusView.update(timeLeft: expirationDate.timeLeft)
        })
    }

    // MARK: setup gesture

    private func setupGesture() {
        let tapPreviewView = UITapGestureRecognizer(target: self, action: #selector(presentExhbtContent))
        previewView.addGestureRecognizer(tapPreviewView)
        previewView.isUserInteractionEnabled = true
    }

    // MARK: Action for tap gesture

    @objc func presentExhbtContent() {
        presentContent(model)
    }
}

extension ExhbtDetailsViewController: Router { }

// MARK: - SingleExhbtCompetitorsViewDelegate

extension ExhbtDetailsViewController: SingleExhbtCompetitorsViewDelegate {
    func willShowChooseCompetitors() {
        guard let exhbtId else { return }
        presentChooseCompetitors(exhbtId: exhbtId, delegate: self)
    }

    func willShowJoinExhbt() {
        guard let exhbtId else { return }
        presentNewCompetition(withExhbt: exhbtId, type: competitionMode ?? .join, delegate: self)
    }

    func singleExhbtCompetitors(willViewUser user: Int) {
        presentUser(withId: user)
    }
}

extension ExhbtDetailsViewController: NewCompetitionDelegate {
    func newCompetitionDidFinishWithInvitation() {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }

    func newCompetitionDidFinish() {
        viewModel.loadData(forExhbt: exhbtId!)
    }
}

// MARK: - SingleExhbtCompetitorsViewDelegate

extension ExhbtDetailsViewController: ChooseCompetitorsDelegate {
    func chooseCompetitorsWillDismiss() {
        if navigationController?.viewControllers.first == self {
            dismiss(animated: true)
        }
    }
}
